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
      consolidate_protocols: Mix.env() == :prod,
      package: package(),
      deps: deps(),
      docs: docs(),
      aliases: aliases(),
      source_url: @github_url,
      homepage_url: @github_url
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
      {:ash, "~> 3.5"},
      {:xml_builder, "~> 2.4"},
      {:spark, "~> 2.2 and >= 2.2.10"},
      {:ex_doc, "~> 0.38", only: :dev, runtime: false},
      {:ecto_sql, "~> 3.13"},
      {:sourceror, "~> 1.7", only: [:dev, :test]},
      {:igniter, "~> 0.3 and >= 0.3.58", optional: true, only: [:dev, :test]},
      {:progress_bar, "~> 3.0", only: [:dev, :test]}
    ]
  end

  defp docs do
    [
      homepage_url: @github_url,
      source_url: @github_url,
      source_ref: "v#{@version}",
      main: "readme",
      extras: [
        "documentation/dsls/DSL-AshSitemap.Resource.md",
        "documentation/topics/sitemaps.md",
        # {"documentation/dsls/DSL-AshSitemap.Resource.md",
        #  search_data: Spark.Docs.search_data_for(AshSitemap.Resource)},
        "README.md": [title: "Guide"],
        "LICENSE.md": [title: "License"]
      ],
      groups_for_extras: [
        Topics: ~r'documentation/topics',
        DSLs: ~r'documentation/dsls'
      ],
      groups_for_modules: [
        AshSitemap: [
          AshSitemap
        ],
        Sitemaps: [
          AshSitemap.Sitemaps.Sitemap,
          AshSitemap.Sitemaps.SitemapIndex,
          AshSitemap.Sitemaps.News,
          AshSitemap.Sitemaps.Image,
          AshSitemap.Sitemaps.Video,
          AshSitemap.Sitemaps.PageMap
        ],
        Introspection: [
          AshSitemap.Resource.Info
        ],
        Internals: ~r/.*/
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
      "spark.cheat_sheets":
        "spark.cheat_sheets --extensions AshSitemap.Resource",
      "spark.cheat_sheets_in_search":
        "spark.cheat_sheets_in_search --extensions AshSitemap.Resource",
      "spark.formatter": [
        "spark.formatter --extensions AshSitemap.Resource",
        "format .formatter.exs"
      ]
    ]
  end
end
