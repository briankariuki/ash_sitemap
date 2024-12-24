defmodule Mix.Tasks.AshSitemap.Gen.Sitemap do
  @moduledoc """
  Generates sitemaps for a given api and resource.

  The api and resource must already exist, this task does not define them.

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

    AshSitemap.Gen.Sitemap.generate_from_cli(argv)
  end
end
