defmodule AshSitemap do
  @moduledoc """
  Documentation for `AshSitemap`.
  """

  alias AshSitemap.Helpers

  @doc """
  Generates sitemaps from resource

  ## Positional Arguments

    - `domain` - The domain (e.g. "Shop").
    - `resource` - The resource (e.g. "Product").

  ## Options

  - `resource_plural` - The plural name of the resource (e.g. "products")
  - `read_action` - The action to use when getting the records from the resource (e.g. "read")
  - `urls_limit` - The maximum number of urls per sitemap file (default: 50000)
  - `query_limit` - The maximum number of records to fetch for each read action (default: 250)

  ## Examples

      iex> AshSitemap.generate(Example.News, Example.Article, resource_plural: "articles")
      GENERATING[article_1.xml]: |█░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░|   2% (1000/50000)

  """
  def generate(domain, resource, opts \\ []) do
    Code.ensure_compiled!(domain)
    Code.ensure_compiled!(resource)

    if !Spark.Dsl.is?(domain, Ash.Domain) do
      raise "#{inspect(domain)} is not a valid Ash Domain module"
    end

    if !Ash.Resource.Info.resource?(resource) do
      raise "#{inspect(resource)} is not a valid Ash Resource module"
    end

    assigns =
      [
        domain: domain,
        resource: resource
      ]
      |> add_resource_assigns(resource, opts)

    read_action = assigns[:read_action]
    resource_plural = assigns[:resource_plural]
    resource_singular = assigns[:resource_singular]

    sitemap_directory =
      Path.join([
        Helpers.root_path(),
        "priv/static/sitemaps"
      ])

    records_count =
      resource
      |> Ash.Query.for_read(read_action.name)
      |> Ash.count!(authorize?: false)

    urls_limit = opts[:urls_limit]
    sitemap_files = Helpers.sitemap_files_count(records_count, urls_limit)

    log_level = Logger.level()
    Logger.configure(level: :warning)

    Task.async_stream(
      1..sitemap_files,
      fn id ->
        write_sitemap_template(
          "#{resource_singular}_#{id}.xml",
          sitemap_directory,
          (id - 1) * urls_limit,
          urls_limit,
          assigns
        )
      end,
      max_concurrency: System.schedulers_online() * 2,
      ordered: true,
      timeout: :infinity
    )
    |> Stream.run()

    write_sitemap_index(
      "#{resource_plural}_index.xml",
      sitemap_directory,
      sitemap_files,
      assigns
    )

    Logger.configure(level: log_level)
  end

  defp write_sitemap_template(
         filename,
         directory,
         offset,
         record_limit,
         assigns
       ) do
    query_limit = assigns[:query_limit]
    read_action = assigns[:read_action]
    resource_plural = assigns[:resource_plural]
    resource = Module.concat([assigns[:resource]])
    domain = Module.concat([assigns[:domain]])

    destination_path =
      directory
      |> Path.join(resource_plural)
      |> Path.join(filename)
      |> Path.expand(File.cwd!())

    # Create file directory
    File.mkdir_p!(Path.dirname(destination_path))

    # Write file header
    File.write!(destination_path, AshSitemap.Helpers.xml_header())

    # Create file stream
    file_stream =
      File.stream!(destination_path, [:append])

    query =
      resource
      |> Ash.Query.for_read(read_action.name)
      |> Ash.Query.offset(offset)
      |> Ash.Query.limit(record_limit)

    # Get total records
    {:ok, total_count} = Ash.count(query, authorize?: false)

    # Generate sitemaps from records
    query
    |> Ash.stream!(
      stream_with: :offset,
      domain: domain,
      batch_size: query_limit,
      authorize?: false
    )
    |> Stream.map(&AshSitemap.Generate.generate/1)
    # |> Stream.map(&List.flatten/1)
    |> Stream.flat_map(fn x -> x end)
    |> Stream.with_index(1)
    |> Stream.map(fn {item, idx} ->
      if idx <= total_count do
        AshSitemap.Helpers.progress_bar(idx, total_count, filename)
      end

      item
    end)
    |> Enum.into(file_stream)

    # Write file footer
    File.write!(destination_path, AshSitemap.Helpers.xml_footer(), [:append])
  end

  defp write_sitemap_index(
         filename,
         directory,
         count,
         assigns
       ) do
    resource_singular = assigns[:resource_singular]

    destination_path =
      directory
      |> Path.join(filename)
      |> Path.expand(File.cwd!())

    File.mkdir_p!(Path.dirname(destination_path))

    {:ok, file} =
      File.open(destination_path, [:write])

    IO.write(file, AshSitemap.Helpers.xml_index_header())

    Enum.map(1..count, fn id ->
      IO.write(
        file,
        AshSitemap.Sitemaps.SitemapIndex.to_xml(
          "#{resource_singular}_#{id}.xml"
        )
      )
    end)

    IO.write(file, AshSitemap.Helpers.xml_index_footer())

    File.close(file)
  end

  defp add_resource_assigns(assigns, resource, opts) do
    short_name =
      resource
      |> Ash.Resource.Info.short_name()
      |> to_string()

    plural_name = opts[:resource_plural]
    url_limit = opts[:url_limit]
    query_limit = opts[:query_limit]
    read_action = opts[:read_action]

    Keyword.merge(assigns,
      resource_singular: short_name,
      resource_alias: Macro.camelize(short_name),
      resource_plural: plural_name,
      read_action: read_action,
      url_limit: url_limit,
      query_limit: query_limit
    )
  end
end
