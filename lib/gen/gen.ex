defmodule AshSitemap.Gen do
  @moduledoc false

  @urls_limit 50000
  @query_limit 250

  def docs do
    """
    ## Positional Arguments

    - `domain` - The API (e.g. "Shop").
    - `resource` - The resource (e.g. "Product").

    ## Options

    - `--resource-plural` - The plural resource name (e.g. "products")
    - `--urls-limit` - The maximum number of urls per sitemap file (default: 50000)
    - `--query-limit` - The maximum number of records to fetch for each read action (default: 250)
    """
  end

  def parse_opts(argv) do
    {domain, resource, rest} =
      case argv do
        [domain, resource | rest] ->
          {domain, resource, rest}

        argv ->
          raise "Not enough arguments. Expected 2, got #{Enum.count(argv)}"
      end

    if String.starts_with?(domain, "-") do
      raise "Expected first argument to be an domain module, not an option"
    end

    if String.starts_with?(resource, "-") do
      raise "Expected second argument to be a resource module, not an option"
    end

    {parsed, _, _} =
      OptionParser.parse(rest,
        strict: [resource_plural: :string, urls_limit: :integer]
      )

    domain = Module.concat([domain])
    resource = Module.concat([resource])

    parsed =
      Keyword.put_new_lazy(rest, :resource_plural, fn ->
        plural_name!(resource, parsed)
      end)

    parsed =
      Keyword.put_new_lazy(parsed, :urls_limit, fn ->
        @urls_limit
      end)

    parsed =
      Keyword.put_new_lazy(parsed, :query_limit, fn ->
        @query_limit
      end)

    {domain, resource, parsed, rest}
  end

  defp plural_name!(resource, opts) do
    plural_name =
      opts[:resource_plural] ||
        Ash.Resource.Info.plural_name(resource) ||
        Mix.shell().prompt(
          """
          Please provide a plural_name for #{inspect(resource)}. For example the plural of tweet is tweets.

          This can also be configured on the resource. To do so, press enter to abort,
          and add the following configuration to your resource (using the proper plural name)

              resource do
                plural_name :tweets
              end
          >
          """
          |> String.trim()
        )
        |> String.trim()

    case plural_name do
      empty when empty in ["", nil] ->
        raise(
          "Must configure `plural_name` on resource or provide --resource-plural"
        )

      plural_name ->
        to_string(plural_name)
    end
  end
end
