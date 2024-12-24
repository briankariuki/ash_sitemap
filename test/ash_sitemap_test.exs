defmodule AshSitemap.Test.Macros do
  defmacro defresource(name, block) do
    quote do
      defmodule unquote(name) do
        use Ash.Resource,
          domain: nil,
          validate_domain_inclusion?: false,
          data_layer: Ash.DataLayer.Ets,
          extensions: [AshSitemap.Resource]

        attributes do
          uuid_primary_key :id, writable?: true
          attribute :title, :string, public?: true
          attribute :description, :string, public?: true
        end

        unquote(block)
      end
    end
  end
end

defmodule AshSitemap.Test do
  use ExUnit.Case
  doctest AshSitemap

  import AshSitemap.Test.Macros

  test "greets the world" do
    assert AshSitemap.hello() == :world
  end

  describe "`host` option" do
    defresource WithHost do
      # jason do
      #   customize fn result, _record ->
      #     result |> Map.put(:c, 1)
      #   end
      # end

      sitemap do
        host "https://example.com"
        compress true
        read_action :read
        file_path("/priv/sitemap.xml")

        url("index.html",
          priority: 0.5,
          news: [
            title: :title,
            publication: "World",
            publication_date: "2021-01-01",
            keywords: ["hello", "world"]
          ]
        )

        # url(fn r -> r.title end,
        #   priority: 1.0,
        #   news: fn _object -> [title: "I work"] end
        # )

        url(fn r -> r.title end,
          priority: 1.0,
          news: [
            title: "Hello",
            publication: "World",
            publication_date: "2021-01-01",
            # publication_date: fn r -> r.title end,
            keywords: ["hello", "world"]
          ]
        )

        # path [{:url, "https://example.com", lastmod: "2021-01-01"}]

        # urls do
        #   url("index.html", priority: 0.5)
        # end
      end
    end

    test "modifies resulted map" do
      # assert encode!(%WithCustomize{id: @id, x: 1, y: 1}) == "{\"id\":\"#{@id}\",\"c\":1,\"x\":1}"

      assert AshSitemap.Generator.generate(%WithHost{
               title: "Hello World",
               description: "This is my first blog post"
             }) ==
               "string"
    end
  end
end
