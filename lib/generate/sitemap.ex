defmodule AshSitemap.Generate.Sitemap do
  @moduledoc false
  def generate_from_cli(argv) do
    {domain, resource, opts, _rest} = AshSitemap.Generate.parse_opts(argv)

    generate(
      domain,
      resource,
      Keyword.put(opts, :interactive?, true)
    )
  end

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
        domain: inspect(domain),
        resource: inspect(resource)
      ]
      |> add_resource_assigns(domain, resource, opts)

    sitemap_directory =
      Path.join([
        root_path(),
        "priv/static/sitemaps"
      ])

    generate_opts =
      if opts[:interactive?] do
        []
      else
        [force: true, quiet: true]
      end

    resource = Module.safe_concat([assigns[:resource]])
    read_action = assigns[:read_action]

    count =
      resource
      |> Ash.Query.for_read(read_action.name)
      |> Ash.count!(authorize?: false)

    urls_limit = opts[:urls_limit]

    sitemap_files = sitemap_files_count(count, urls_limit)

    Task.async_stream(
      1..sitemap_files,
      fn id ->
        write_sitemap_template(
          "#{assigns[:resource_singular]}_#{id}.xml",
          sitemap_directory,
          assigns,
          (id - 1) * urls_limit,
          urls_limit,
          generate_opts
        )
      end,
      max_concurrency: System.schedulers_online() * 2,
      ordered: true,
      timeout: :infinity
    )
    |> Stream.run()

    write_sitemap_index(
      "#{assigns[:resource_singular]}",
      sitemap_directory,
      assigns,
      sitemap_files,
      generate_opts
    )
  end

  defp write_sitemap_template(
         destination,
         sitemap_directory,
         assigns,
         offset,
         record_limit,
         _generate_opts
       ) do
    destination_path =
      sitemap_directory
      |> Path.join(destination)
      |> Path.expand(File.cwd!())

    File.mkdir_p!(Path.dirname(destination_path))

    resource = Module.safe_concat([assigns[:resource]])
    read_action = assigns[:read_action]

    {:ok, file} =
      File.open(destination_path, [:write])

    IO.write(file, AshSitemap.File.xml_header())

    query_limit = assigns[:query_limit]

    query =
      resource
      |> Ash.Query.for_read(read_action.name)
      |> Ash.Query.limit(query_limit)

    Stream.resource(
      fn -> offset end,
      fn
        false ->
          {:halt, nil}

        read_offset ->
          query =
            query
            |> Ash.Query.offset(read_offset)

          if read_offset >= record_limit + offset do
            {[], false}
          else
            case Ash.read!(query, authorize?: false) do
              [] ->
                {[], false}

              results ->
                {results, read_offset + query_limit}
            end
          end
      end,
      & &1
    )
    |> Stream.map(&AshSitemap.Generator.generate/1)
    |> Stream.each(fn xml_urls ->
      urls = List.flatten(xml_urls)
      IO.write(file, urls)
    end)
    |> Stream.run()

    IO.write(file, AshSitemap.File.xml_footer())

    File.close(file)
  end

  defp write_sitemap_index(
         destination,
         sitemap_index_directory,
         _assigns,
         count,
         _generate_opts
       ) do
    destination_path =
      sitemap_index_directory
      |> Path.join("sitemap_index.xml")
      |> Path.expand(File.cwd!())

    File.mkdir_p!(Path.dirname(destination_path))

    {:ok, file} =
      File.open(destination_path, [:write])

    IO.write(file, AshSitemap.File.xml_index_header())

    Enum.map(1..count, fn id ->
      IO.write(file, AshSitemap.IndexUrl.to_xml("#{destination}_#{id}.xml"))
    end)

    IO.write(file, AshSitemap.File.xml_index_footer())

    File.close(file)
  end

  defp add_resource_assigns(assigns, _domain, resource, opts) do
    short_name =
      resource
      |> Ash.Resource.Info.short_name()
      |> to_string()

    plural_name = opts[:resource_plural]
    url_limit = opts[:url_limit]
    query_limit = opts[:query_limit]
    read_action = action(resource, opts, :read)

    Keyword.merge(assigns,
      resource_singular: short_name,
      resource_alias: Macro.camelize(short_name),
      resource_plural: plural_name,
      read_action: read_action,
      url_limit: url_limit,
      query_limit: query_limit,
      attrs: attrs(resource)
    )
  end

  defp attrs(resource) do
    resource
    |> Ash.Resource.Info.public_attributes()
  end

  defp action(resource, opts, type) do
    action =
      case opts[:"#{type}_action"] do
        nil ->
          Ash.Resource.Info.primary_action(resource, type)

        action ->
          case Ash.Resource.Info.action(resource, action, type) do
            nil ->
              raise "No such #{type} action #{inspect(action)}"

            action ->
              action
          end
      end

    if opts[:interactive?] && !action do
      actions =
        resource
        |> Ash.Resource.Info.actions()
        |> Enum.filter(&(&1.type == type))

      if Enum.empty?(actions) do
        if Mix.shell().yes?(
             "Primary #{type} action not found, and a #{type} action not supplied. Would you like to create one?"
           ) do
          if Mix.shell().yes?("""
             This is a manual step currently. Please add a primary #{type} action or designate one as primary, and then select Y.
             Press anything else to cancel and proceed with no update action.
             """) do
            action(resource, opts, type)
          end
        end
      else
        if Mix.shell().yes?(
             "Primary #{type} action not found. Would you like to use one of the following?:\n#{Enum.map_join(actions, "\n", &"- #{&1.name}")}"
           ) do
          action =
            Mix.shell().prompt(
              """
              Please enter the name of the action you would like to use.
              Press enter to cancel and proceed with no #{type} action.
              >
              """
              |> String.trim()
            )
            |> String.trim()

          case action do
            "" ->
              nil

            action ->
              action(
                resource,
                Keyword.put(opts, :"#{type}_action", action),
                type
              )
          end
        else
          if Mix.shell().yes?("Would you like to create one?") do
            if Mix.shell().yes?("""
               This is a manual step currently. Please add a primary #{type} action or designate one as primary, and then select Y.
               Press anything else to cancel and proceed with no #{type} action.
               """) do
              action(resource, opts, type)
            end
          end
        end
      end
    else
      action
    end
  end

  defp root_path do
    Mix.Project.get().module_info()[:compile][:source]
    |> Path.dirname()
  end

  defp sitemap_files_count(count, limit) when count < limit do
    1
  end

  defp sitemap_files_count(count, limit) do
    {quotient, remainder} = AshSitemap.Helpers.divmod(count, limit)

    if remainder > 0 do
      quotient + 1
    else
      quotient
    end
  end
end
