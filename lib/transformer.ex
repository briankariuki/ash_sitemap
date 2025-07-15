defmodule AshSitemap.Transformer do
  @moduledoc false

  use Spark.Dsl.Transformer
  require XmlBuilder

  def transform(dsl) do
    sitemaps = Spark.Dsl.Transformer.get_entities(dsl, [:sitemaps])

    defimpl AshSitemap.Generate, for: dsl.persist.module do
      @sitemaps sitemaps

      def generate(record) do
        sitemaps =
          Enum.map(@sitemaps, fn sitemap ->
            AshSitemap.Sitemaps.Sitemap.build(record, sitemap)
          end)

        Enum.map(sitemaps, fn sitemap ->
          (AshSitemap.Build.to_xml(sitemap) |> XmlBuilder.generate()) <>
            "\n"
        end)
      end
    end

    :ok
  end
end
