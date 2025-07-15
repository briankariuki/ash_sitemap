defmodule AshSitemap.Sitemaps.SitemapIndex do
  alias AshSitemap.Build
  require XmlBuilder

  def to_xml(index, opts \\ []) do
    (Build.index(index, opts) |> XmlBuilder.generate()) <> "\n"
  end
end
