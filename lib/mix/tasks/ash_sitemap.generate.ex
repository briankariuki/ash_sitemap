defmodule Mix.Tasks.AshSitemap.Generate do
  @moduledoc """
  Generates sitemaps for a given domain and resource.

  The domain and resource must already exist, this task does not define them.

  #{AshSitemap.Gen.docs()}

  For example:

  ```bash
  mix ash_sitemap.generate ExistingDomainName ExistingResourceName
  ```
  """
  use Mix.Task

  @shortdoc "Generates sitemaps for a resource"
  def run(argv) do
    Mix.Task.run("app.start", [])

    if Mix.Project.umbrella?() do
      Mix.raise(
        "mix ash_sitemap.generate must be invoked from within your *_web application root directory"
      )
    end

    generate_from_cli(argv)
  end

  def generate_from_cli(argv) do
    {domain, resource, opts, _rest} = AshSitemap.Gen.parse_opts(argv)

    AshSitemap.generate(
      domain,
      resource,
      opts
    )
  end
end
