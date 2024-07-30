defmodule AshSitemap.MixProject do
  use Mix.Project

  @name :ash_sitemap
  @version "1.0.1"
  @description "Ash extension for generating sitemaps"
  @github_url "https://github.com/briankariuki/ash_sitemap"

  def project do
    [
      app: @name,
      version: @version,
      elixir: "~> 1.17",
      start_permanent: Mix.env() == :prod,
      consolidate_protocols: Mix.env() != :test,
      package: package(),
      deps: deps(),
      docs: docs(),
      aliases: aliases()
    ]
  end

  def application do
    [
      extra_applications: [:logger]
    ]
  end

  defp package() do
    [
      maintainers: ["Brian Kariuki"],
      description: @description,
      licenses: ["MIT"],
      links: %{Github: @github_url},
      files: ~w(mix.exs lib .formatter.exs LICENSE.md  README.md)
    ]
  end

  defp deps do
    [
      {:ash, "~> 3.2"},
      {:xml_builder, "~> 2.1"},
      {:spark, "~> 2.2.10 and < 3.0.0"},
      {:ex_doc, "~> 0.32", only: :dev, runtime: false}
    ]
  end

  def docs() do
    [
      homepage_url: @github_url,
      source_url: @github_url,
      source_ref: "v#{@version}",
      main: "readme",
      extras: [
        "README.md": [title: "Guide"],
        "LICENSE.md": [title: "License"],
        "documentation/dsls/DSL:-AshSitemap.Resource.md": [title: "DSL: AshSitemap.Resource"]
      ]
    ]
  end

  defp aliases() do
    [
      docs: [
        "spark.cheat_sheets",
        "docs",
        "spark.replace_doc_links",
        "spark.cheat_sheets_in_search"
      ],
      "spark.cheat_sheets": "spark.cheat_sheets --extensions AshSitemap.Resource",
      "spark.cheat_sheets_in_search":
        "spark.cheat_sheets_in_search --extensions AshSitemap.Resource",
      "spark.formatter": [
        "spark.formatter --extensions AshSitemap.Resource",
        "format .formatter.exs"
      ]
    ]
  end
end
