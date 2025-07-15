defmodule AshSitemap.Sitemaps.PageMap.DataObject do
  @moduledoc """
  A struct module representing a pagemap dataobject. This module can also be used to implement manual pagemap dataobjects.

  See more https://developers.google.com/search/docs/crawling-indexing/sitemaps/news-sitemap
  """

  @callback generate(record :: Ash.Resource.t()) :: __MODULE__.t()

  defmacro __using__(_opts) do
    quote do
      @behaviour AshSitemap.Sitemaps.PageMap.DataObject
    end
  end

  @enforce_keys [
    :type
  ]
  @fields quote(
            do: [
              type: String.t(),
              id: String.t() | nil,
              attribute: [AshSitemap.Sitemaps.PageMap.DataObject.Attribute.t()]
            ]
          )
  @derive []
  defstruct Keyword.keys(@fields)

  @type t() :: %__MODULE__{unquote_splicing(@fields)}
end
