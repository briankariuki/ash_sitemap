defmodule AshSitemap.Sitemaps.News do
  @moduledoc """
  A struct module representing a news sitemap. This module can also be used to implement manual news sitemaps.

  See more https://developers.google.com/search/docs/crawling-indexing/sitemaps/news-sitemap
  """

  @callback generate(record :: Ash.Resource.t()) :: __MODULE__.t()

  defmacro __using__(_opts) do
    quote do
      @behaviour AshSitemap.Sitemaps.News
    end
  end

  @enforce_keys [
    :title,
    :publication_date,
    :publication_name,
    :publication_language
  ]
  @fields quote(
            do: [
              title: String.t(),
              keywords: [String.t()],
              stock_tickers: [String.t()],
              genres: String.t() | nil,
              access: String.t() | nil,
              publication_name: String.t(),
              publication_language: String.t(),
              publication_date: String.t()
            ]
          )
  @derive []
  defstruct Keyword.keys(@fields)

  @type t() :: %__MODULE__{unquote_splicing(@fields)}
end
