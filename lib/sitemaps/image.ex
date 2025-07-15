defmodule AshSitemap.Sitemaps.Image do
  @moduledoc """
  A struct module representing an image sitemap. This module can also be used to implement manual image sitemaps.

  See more https://developers.google.com/search/docs/crawling-indexing/sitemaps/news-sitemap
  """

  @callback generate(record :: Ash.Resource.t()) :: __MODULE__.t()

  defmacro __using__(_opts) do
    quote do
      @behaviour AshSitemap.Sitemaps.Image
    end
  end

  @enforce_keys [
    :loc
  ]
  @fields quote(
            do: [
              loc: String.t(),
              title: String.t() | nil,
              geo_location: String.t() | nil,
              caption: String.t() | nil,
              license: String.t() | nil
            ]
          )
  @derive []
  defstruct Keyword.keys(@fields)

  @type t() :: %__MODULE__{unquote_splicing(@fields)}
end
