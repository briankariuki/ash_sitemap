defmodule AshSitemap.Generate do
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
        ""
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
end
