defmodule AshSitemap.IndexUrl do
  alias AshSitemap.Build
  require XmlBuilder

  def to_xml(url, opts \\ []) do
    (Build.index(url, opts) |> XmlBuilder.generate()) <> "\n"
  end
end
