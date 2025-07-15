defmodule AshSitemap.Sitemaps.Video do
  @moduledoc """
  A struct representing a video sitemap. This module can also be used to implement manual video sitemaps.

  See more at https://developers.google.com/search/docs/crawling-indexing/sitemaps/video-sitemaps
  """

  @callback generate(record :: Ash.Resource.t()) :: __MODULE__.t()

  defmacro __using__(_opts) do
    quote do
      @behaviour AshSitemap.Sitemaps.Video
    end
  end

  @enforce_keys [
    :title,
    :description,
    :content_loc,
    :thumbnail_loc,
    :player_loc
  ]
  @fields quote(
            do: [
              title: String.t(),
              description: String.t(),
              content_loc: String.t(),
              thumbnail_loc: String.t(),
              player_loc: String.t(),
              allow_embed?: boolean() | nil,
              autoplay?: boolean() | nil,
              duration: non_neg_integer() | nil,
              expiration_date: String.t() | nil,
              rating: float() | nil,
              view_count: non_neg_integer() | nil,
              publication_date: String.t() | nil,
              category: String.t() | nil,
              family_friendly?: boolean() | nil,
              restriction: [String.t()],
              relationship?: boolean() | nil,
              gallery_loc: String.t() | nil,
              gallery_title: String.t() | nil,
              price: String.t() | nil,
              price_currency: String.t() | nil,
              price_type: String.t() | nil,
              price_resolution: String.t() | nil,
              requires_subscription?: boolean() | nil,
              uploader: String.t() | nil,
              uploader_info: String.t() | nil,
              live?: boolean() | nil,
              show_title: String.t() | nil,
              show_video_type: String.t() | nil,
              show_episode_title: String.t() | nil,
              show_season_number: non_neg_integer() | nil,
              show_episode_number: non_neg_integer() | nil,
              show_premier_date: String.t() | nil,
              platform_list: [String.t()],
              platform_relationship?: boolean() | nil
            ]
          )
  @derive []
  defstruct Keyword.keys(@fields)

  @type t() :: %__MODULE__{unquote_splicing(@fields)}
end
