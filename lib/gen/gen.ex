defmodule AshSitemap.Gen do
  @moduledoc false

  @urls_limit 50000
  @query_limit 250

  def docs do
    """
    ## Positional Arguments

    - `domain` - The domain (e.g. "Shop").
    - `resource` - The resource (e.g. "Product").

    ## Options

    - `--hostname` - The base url of the website serving the content in the resource.
    - `--resource-plural` - The plural resource name (e.g. "products")
    - `--read-action` - The action to use when getting the records from the resource (e.g. "read")
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

    domain = Module.concat([domain])
    resource = Module.concat([resource])

    {parsed, _, _} =
      OptionParser.parse(rest,
        strict: [
          resource_plural: :string,
          read_action: :string,
          urls_limit: :integer,
          query_limit: :integer
        ]
      )

    parsed = Keyword.put(parsed, :interactive?, true)

    parsed =
      Keyword.put_new_lazy(parsed, :resource_plural, fn ->
        plural_name!(resource, parsed)
      end)

    parsed =
      Keyword.put_new_lazy(parsed, :read_action, fn ->
        action!(resource, :read, parsed)
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

  defp action!(resource, type, opts) do
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
            action!(resource, type, opts)
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
            empty when empty in ["", nil] ->
              raise(
                "Must configure primary read action on resource or provide --read-action"
              )

            action ->
              action!(
                resource,
                type,
                Keyword.put(opts, :"#{type}_action", action)
              )
          end
        end
      end
    else
      action
    end
  end
end
