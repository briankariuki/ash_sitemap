defmodule AshSitemap.Transformer do
  @moduledoc false

  use Spark.Dsl.Transformer
  require XmlBuilder

  def transform(dsl) do
    host = Spark.Dsl.Transformer.get_option(dsl, [:sitemap], :host, %{})
    compress = Spark.Dsl.Transformer.get_option(dsl, [:sitemap], :compress, %{})

    read_action =
      Spark.Dsl.Transformer.get_option(dsl, [:sitemap], :read_action)

    file_path = Spark.Dsl.Transformer.get_option(dsl, [:sitemap], :file_path)
    urls = Spark.Dsl.Transformer.get_entities(dsl, [:sitemap])

    # customize = Spark.Dsl.Transformer.get_option(dsl, [:jason], :customize, &AshJason.Transformer.default_customize/2)

    defimpl AshSitemap.Generate, for: dsl.persist.module do
      @host host
      @compress compress
      @urls urls
      @read_action read_action
      @file_path file_path

      def generate(record) do
        urls =
          Enum.map(@urls, fn url ->
            AshSitemap.Url.map(record, url,
              host: @host,
              compress: @compress,
              file_path: @file_path,
              read_action: @read_action
            )
          end)

        Enum.map(urls, fn url ->
          (AshSitemap.Url.to_xml(url) |> XmlBuilder.generate()) <> "\n"
        end)
        |> List.flatten()
      end
    end

    :ok
  end

  def default_customize(result, _record), do: result
end
