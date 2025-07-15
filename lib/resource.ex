defmodule AshSitemap.Resource do
  @moduledoc """
  Ash resource extension for generating sitemaps.
  """

  @news %Spark.Dsl.Entity{
    name: :news,
    target: AshSitemap.Sitemaps.News,
    examples: [],
    schema: [
      publication_date: [
        type: {
          :or,
          [:string, :atom, {:fun, [:map], :string}]
        },
        required: true,
        doc:
          "Article publication date in W3C format, specifying the complete date (YYYY-MM-DD) with optional timestamp. See: http://www.w3.org/TR/NOTE-datetime Please ensure that you give the original date and time at which the article was published on your site; do not give the time at which the article was added to your Sitemap. Required."
      ],
      publication_name: [
        type: {
          :or,
          [:string, :atom, {:fun, [:map], :string}]
        },
        required: true,
        doc:
          "Name of the news publication. It must exactly match the name as it appears on your articles in news.google.com, omitting any trailing parentheticals. For example, if the name appears in Google News as 'The Example Times (subscription)', you should use 'The Example Times'. Required."
      ],
      publication_language: [
        type: {
          :or,
          [:string, :atom, {:fun, [:map], :string}]
        },
        required: true,
        doc:
          "Language of the publication. It should be an ISO 639 Language Code (either 2 or 3 letters); see: http://www.loc.gov/standards/iso639-2/php/code_list.php Exception: For Chinese, please use zh-cn for Simplified Chinese or zh-tw for Traditional Chinese. Required."
      ],
      access: [
        type: {
          :or,
          [:string, :atom, {:fun, [:map], :string}]
        },
        doc:
          "Accessibility of the article. Required if access is not open, otherwise this tag should be omitted."
      ],
      genres: [
        type: {
          :or,
          [:string, :atom, {:fun, [:map], :string}]
        },
        doc:
          "A comma-separated list of properties characterizing the content of the article, such as 'PressRelease' or 'UserGenerated'. For a list of possible values, see: https://www.google.com/support/news_pub/bin/answer.py?answer=93992 Required if any genres apply to the article, otherwise this tag should be omitted."
      ],
      title: [
        type: {
          :or,
          [:string, :atom]
        },
        required: true,
        doc:
          "Title of the news article. Required. Note: The title may be truncated for space reasons when shown on Google News."
      ],
      keywords: [
        type: {
          :or,
          [{:list, :string}, {:fun, [:map], {:list, :string}}]
        },
        doc:
          "Comma-separated list of keywords describing the topic of the article. Keywords may be drawn from, but are not limited to, the list of existing Google News keywords; see: https://www.google.com/support/news_pub/bin/answer.py?answer=116037 Optional."
      ],
      stock_tickers: [
        type: {
          :or,
          [{:list, :string}, {:fun, [:map], {:list, :string}}]
        },
        doc:
          "Comma-separated list of up to 5 stock tickers of the companies, mutual funds, or other financial entities that are the main subject of the article. Relevant primarily for business articles. Each ticker must be prefixed by the name of its stock exchange, and must match its entry in Google Finance. For example, 'NASDAQ:AMAT' (but not 'NASD:AMAT'), or 'BOM:500325' (but not 'BOM:RIL'). Optional."
      ]
    ]
    # no_depend_modules: [:news],
    # args: [:news]
  }

  @image %Spark.Dsl.Entity{
    name: :image,
    target: AshSitemap.Sitemaps.Image,
    examples: [
      """
        sitemap do
          path "index.html"
          priority 0.5

          image do
            loc &1.image_url end
          end
        end
      """
    ],
    schema: [
      loc: [
        type: {
          :or,
          [:string, {:fun, [:map], :string}]
        },
        required: true,
        doc: "The URL of the image."
      ],
      caption: [
        type: {
          :or,
          [:string, {:fun, [:map], :string}]
        },
        required: false,
        doc: "The caption of the image."
      ],
      geo_location: [
        type: {
          :or,
          [:string, {:fun, [:map], :string}]
        },
        required: false,
        doc:
          "The geographic location of the image. For example, 'Limerick, Ireland'."
      ],
      title: [
        type: {
          :or,
          [:string, {:fun, [:map], :string}]
        },
        required: false,
        doc: "The title of the image."
      ],
      license: [
        type: {
          :or,
          [:string, {:fun, [:map], :string}]
        },
        required: false,
        doc: "A URL to the license of the image."
      ]
    ]
  }

  @video %Spark.Dsl.Entity{
    name: :video,
    target: AshSitemap.Sitemaps.Video,
    examples: [],
    schema: [
      title: [
        type: {
          :or,
          [:string, {:fun, [:map], :string}]
        },
        required: true,
        doc: "The title of the video."
      ],
      description: [
        type: {
          :or,
          [:string, {:fun, [:map], :string}]
        },
        required: true,
        doc: "The description of the video."
      ],
      content_loc: [
        type: {
          :or,
          [:string, {:fun, [:map], :string}]
        },
        required: true,
        doc:
          "At least one of <video:player_loc> and <video:content_loc> is required. This should be a .mpg, .mpeg, .mp4, .m4v, .mov, .wmv, .asf, .avi, .ra, .ram, .rm, .flv, or other video file format, and can be omitted if <video:player_loc> is specified. However, because Google needs to be able to check that the Flash object is actually a player for video (as opposed to some other use of Flash, e.g. games and animations), it's helpful to provide both."
      ],
      thumbnail_loc: [
        type: {
          :or,
          [:string, {:fun, [:map], :string}]
        },
        required: true,
        doc:
          "A URL pointing to the URL for the video thumbnail image file. We can accept most image sizes/types but recommend your thumbnails are at least 120x90 pixels in .jpg, .png, or. gif formats."
      ],
      player_loc: [
        type: {
          :or,
          [:string, {:fun, [:map], :string}]
        },
        required: true,
        doc:
          "At least one of <video:player_loc> and <video:content_loc> is required. A URL pointing to a Flash player for a specific video. In general, this is the information in the src element of an <embed> tag and should not be the same as the content of the <loc> tag. Since each video is uniquely identified by its content URL (the location of the actual video file) or, if a content URL is not present, a player URL (a URL pointing to a player for the video), you must include either the <video:player_loc> or <video:content_loc> tags. If these tags are omitted and we can't find this information, we'll be unable to index your video."
      ],
      allow_embed?: [
        type: {
          :or,
          [:boolean, {:fun, [:map], :boolean}]
        },
        required: false,
        doc:
          "Attribute allow_embed specifies whether Google can embed the video in search results. Allowed values are 'Yes' or No'. The default value is 'Yes'."
      ],
      autoplay?: [
        type: {
          :or,
          [:boolean, {:fun, [:map], :boolean}]
        },
        required: false,
        doc:
          "User-defined string that Google may append (if appropriate) to the flashvars parameter to enable autoplay of the video."
      ],
      duration: [
        type: {
          :or,
          [:non_neg_integer, {:fun, [:map], :non_neg_integer}]
        },
        required: false,
        doc: "The duration of the video in seconds."
      ],
      expiration_date: [
        type: {
          :or,
          [:string, {:fun, [:map], :string}]
        },
        required: false,
        doc:
          "The date after which the video will no longer be available, in W3C format. Acceptable values are complete date (YYYY-MM-DD) and complete date plus hours, minutes and seconds, and timezone (YYYY-MM-DDThh:mm:ss+TZD). For example, 2007-07-16T19:20:30+08:00. Don't supply this information if your video does not expire."
      ],
      rating: [
        type: {
          :or,
          [:float, {:fun, [:map], :float}]
        },
        required: false,
        doc: "The rating of the video."
      ],
      view_count: [
        type: {
          :or,
          [:non_neg_integer, {:fun, [:map], :non_neg_integer}]
        },
        required: false,
        doc: "The number of times the video has been viewed."
      ],
      publication_date: [
        type: {
          :or,
          [:string, {:fun, [:map], :string}]
        },
        required: false,
        doc:
          "The date the video was first published, in W3C format. Acceptable values are complete date (YYYY-MM-DD) and complete date plus hours, minutes and seconds, and timezone (YYYY-MM-DDThh:mm:ss+TZD). For example, 2007-07-16T19:20:30+08:00."
      ],
      category: [
        type: {
          :or,
          [:string, {:fun, [:map], :string}]
        },
        required: false,
        doc:
          "The video's category - for example, cooking. In general, categories are broad groupings of content by subject. For example, a site about cooking could have categories for Broiling, Baking, and Grilling."
      ],
      family_friendly?: [
        type: {
          :or,
          [:boolean, {:fun, [:map], :boolean}]
        },
        required: false,
        doc:
          "Whether the video is suitable for viewing by children. No if the video should be available only to users with SafeSearch turned off."
      ],
      restriction: [
        type: {
          :or,
          [{:list, :string}, {:fun, [:map], {:list, :string}}]
        },
        required: false,
        doc:
          "A list of countries where the video may or may not be played. If there is no <video:restriction> tag, it is assumed that the video can be played in all territories."
      ],
      relationship?: [
        type: {
          :or,
          [:boolean, {:fun, [:map], :boolean}]
        },
        required: false,
        doc:
          "Attribute 'relationship' specifies whether the video is restricted or permitted for the specified countries."
      ],
      gallery_loc: [
        type: {
          :or,
          [:string, {:fun, [:map], :string}]
        },
        required: false,
        doc:
          "A link to the gallery (collection of videos) in which this video appears."
      ],
      gallery_title: [
        type: {
          :or,
          [:string, {:fun, [:map], :string}]
        },
        required: false,
        doc: "The title of the gallery."
      ],
      price: [
        type: {
          :or,
          [:string, {:fun, [:map], :string}]
        },
        required: false,
        doc:
          "The price to download or view the video. More than one <video:price> element can be listed (for example, in order to specify various currencies). The price value must either be a non-negative decimal or be empty. If a price value is specified, the currency attribute is required. If no price value is specified, the type attribute must be valid and present. The resolution attribute is optional."
      ],
      price_currency: [
        type: {
          :or,
          [:string, {:fun, [:map], :string}]
        },
        required: false,
        doc:
          "The currency in ISO 4217 format. This attribute is required if a value is given for price."
      ],
      price_type: [
        type: {
          :or,
          [:string, {:fun, [:map], :string}]
        },
        required: false,
        doc:
          "The type (purchase or rent) of price. This value is required if there is no value given for price. Values include purchase, PURCHASE, rent, RENT."
      ],
      price_resolution: [
        type: {
          :or,
          [:string, {:fun, [:map], :string}]
        },
        required: false,
        doc: "The resolution of the video at this price (SD or HD)."
      ],
      requires_subscription?: [
        type: {
          :or,
          [:boolean, {:fun, [:map], :boolean}]
        },
        required: false,
        doc:
          "Indicates whether a subscription (either paid or free) is required to view the video."
      ],
      uploader: [
        type: {
          :or,
          [:string, {:fun, [:map], :string}]
        },
        required: false,
        doc: "A name or handle of the video's uploader."
      ],
      uploader_info: [
        type: {
          :or,
          [:string, {:fun, [:map], :string}]
        },
        required: false,
        doc:
          "The URL of a webpage with additional information about this uploader. This URL must be on the same domain as the <loc> tag."
      ],
      live?: [
        type: {
          :or,
          [:boolean, {:fun, [:map], :boolean}]
        },
        required: false,
        doc: "Whether the video is a live internet broadcast."
      ],
      show_title: [
        type: {
          :or,
          [:string, {:fun, [:map], :string}]
        },
        required: false,
        doc:
          "The title of the TV show. This should be the same for all episodes from the same series."
      ],
      show_video_type: [
        type: {
          :or,
          [:string, {:fun, [:map], :string}]
        },
        required: false,
        doc:
          "Describes the relationship of the video to the specified TV show/episode. Allowed values are 'clip', 'full', 'preview', 'interview', 'news', 'other'. "
      ],
      show_episode_title: [
        type: {
          :or,
          [:string, {:fun, [:map], :string}]
        },
        required: false,
        doc:
          "The title of the episode—for example, 'Flesh and Bone' is the title of the Season 1, Episode 8 episode of Battlestar Galactica. This tag is not necessary if the video is not related to a specific episode (for example, if it's a trailer for an entire series or season). "
      ],
      show_season_number: [
        type: {
          :or,
          [:non_neg_integer, {:fun, [:map], :non_neg_integer}]
        },
        required: false,
        doc: "Only for shows with a per-season schedule. "
      ],
      show_episode_number: [
        type: {
          :or,
          [:non_neg_integer, {:fun, [:map], :non_neg_integer}]
        },
        required: false,
        doc:
          "The episode number in number format. For TV shoes with a per-season schedule, the first episode of each series should be numbered "
      ],
      show_premier_date: [
        type: {
          :or,
          [:string, {:fun, [:map], :string}]
        },
        required: false,
        doc:
          "The date the content of the video was first broadcast, in W3C format (for example, 2010-11-05.)"
      ],
      platform_list: [
        type: {
          :or,
          [{:list, :string}, {:fun, [:map], {:list, :string}}]
        },
        required: false,
        doc:
          "A list of platforms where the video may or may not be played. If there is no <video:platform> tag, it is assumed that the video can be played on all platforms."
      ],
      platform_relationship?: [
        type: {
          :or,
          [:boolean, {:fun, [:map], :boolean}]
        },
        required: false,
        doc:
          "Specifies whether the video is restricted or permitted for the specified platforms."
      ]
    ]
  }

  @sitemap %Spark.Dsl.Entity{
    name: :sitemap,
    target: AshSitemap.Sitemaps.Sitemap,
    examples: [
      """
        sitemap do
          path "index.html"
          priority 0.5

          news do
            publication_date fn article ->  article.date end
          end
        end
      """
    ],
    schema: [
      name: [
        type: {
          :or,
          [:string, :atom]
        },
        doc: "A name to identify the news sitemap entity",
        required: true
      ],
      path: [
        type: {
          :or,
          [:string, {:fun, [:map], :string}]
        },
        required: true,
        doc: "The web url path to append to the hostname"
      ],
      priority: [
        type: :float,
        required: true,
        doc: "The priority of the sitemap content"
      ],
      read_action: [
        type: :atom,
        required: false,
        doc: "The read action to use when fetching the records.
          By default will use the`read` action if any"
      ]
    ],
    entities: [
      video: [@video],
      image: [@image],
      news: [@news]
    ],
    singleton_entity_keys: [:news],
    args: [:name]
  }

  @sitemaps %Spark.Dsl.Section{
    name: :sitemaps,
    describe: """
    A section for declaring sitemaps configurations.

    See the [sitemaps guide](/documentation/topics/sitemaps.md) for more.
    """,
    examples: [],
    entities: [
      @sitemap
    ],
    schema: []
  }

  @sections [@sitemaps]

  @transformers [AshSitemap.Transformer]

  @verifiers []

  use Spark.Dsl.Extension,
    sections: @sections,
    transformers: @transformers,
    verifiers: @verifiers
end
