defmodule AshSitemap.Sitemaps.PageMap.DataObject.Attribute do
  @moduledoc """
  A struct module representing a dataobject attribute. This module can also be used to implement manual dataobject attributes.

  See more https://developers.google.com/search/docs/crawling-indexing/sitemaps/news-sitemap
  """

  @callback generate(record :: Ash.Resource.t()) :: __MODULE__.t()

  defmacro __using__(_opts) do
    quote do
      @behaviour AshSitemap.Sitemaps.PageMap.DataObject.Attribute
    end
  end

  @enforce_keys [
    :name
  ]
  @fields quote(
            do: [
              name: String.t(),
              value: String.t() | nil
            ]
          )
  @derive []
  defstruct Keyword.keys(@fields)

  @type t() :: %__MODULE__{unquote_splicing(@fields)}
end
