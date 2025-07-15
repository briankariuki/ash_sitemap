defmodule AshSitemap.Sitemaps.PageMap do
  @moduledoc """
  A struct module representing a pagemap sitemap. This module can also be used to implement manual pagemap sitemaps.

  See more https://developers.google.com/search/docs/crawling-indexing/sitemaps/news-sitemap
  Schema https://www.google.com/schemas/sitemap-pagemap/1.0/sitemap-pagemap.xsd
  """

  @callback generate(record :: Ash.Resource.t()) :: __MODULE__.t()

  defmacro __using__(_opts) do
    quote do
      @behaviour AshSitemap.Sitemaps.PageMap
    end
  end

  @enforce_keys []
  @fields quote(
            do: [
              dataobject: [AshSitemap.Sitemaps.PageMap.DataObject.t()]
            ]
          )
  @derive []
  defstruct Keyword.keys(@fields)

  @type t() :: %__MODULE__{unquote_splicing(@fields)}
end
