defmodule AshSitemap.Build do
  @moduledoc """
  Builder functions for generating xml sitemaps
  """
  alias AshSitemap.Helpers

  import XmlBuilder

  @doc false
  def to_xml(data) do
    hostname = AshSitemap.Config.hostname()

    elms =
      element(
        :url,
        Helpers.eraser([
          element(:loc, Path.join(hostname, data.path || "")),
          element(
            :lastmod,
            Helpers.iso8601(Map.get(data, :lastmod, DateTime.utc_now()))
          ),
          element(:expires, Map.get(data, :expires)),
          element(:changefreq, Map.get(data, :changefreq)),
          element(:priority, Map.get(data, :priority))
        ])
      )

    news = Map.get(data, :news)
    images = Map.get(data, :image)
    videos = Map.get(data, :video)
    mobile = Map.get(data, :mobile)
    geo = Map.get(data, :geo)
    pagemap = Map.get(data, :pagemap)

    elms = ifput(mobile, elms, &append_last(&1, mobile()))
    elms = ifput(geo, elms, &append_last(&1, geo(geo)))
    elms = ifput(news, elms, &append_last(&1, news(news)))
    elms = ifput(images, elms, &append_last(&1, images(images)))
    elms = ifput(videos, elms, &append_last(&1, videos(videos)))
    elms = ifput(pagemap, elms, &append_last(&1, pagemap(pagemap)))

    elms
  end

  @doc """
  Generate a news sitemap element
  """
  def news(data) do
    element(
      :"news:news",
      Helpers.eraser([
        element(
          :"news:publication",
          Helpers.eraser([
            element(:"news:name", data[:publication_name]),
            element(:"news:language", data[:publication_language])
          ])
        ),
        element(:"news:title", data[:title]),
        element(:"news:access", data[:access]),
        element(:"news:genres", data[:genres]),
        element(:"news:keywords", data[:keywords]),
        element(:"news:stock_tickers", data[:stock_tickers]),
        element(
          :"news:publication_date",
          Helpers.iso8601(data[:publication_date])
        )
      ])
    )
  end

  @doc """
  Generate an image sitemap element
  """
  def images(list, elements \\ [])
  def images([], elements), do: elements

  def images([{_, _} | _] = list, elements) do
    images([list], elements)
  end

  def images([data | tail], elements) do
    hostname = AshSitemap.Config.hostname()

    elm =
      element(
        :"image:image",
        Helpers.eraser([
          element(:"image:loc", Path.join(hostname, data[:loc] || "")),
          unless(is_nil(data[:title]),
            do: element(:"image:title", data[:title])
          ),
          unless(is_nil(data[:license]),
            do: element(:"image:license", data[:license])
          ),
          unless(is_nil(data[:caption]),
            do: element(:"image:caption", data[:caption])
          ),
          unless(is_nil(data[:geo_location]),
            do: element(:"image:geo_location", data[:geo_location])
          )
        ])
      )

    images(tail, elements ++ [elm])
  end

  @doc """
  Generate a geo sitemap element
  """
  def geo(data) do
    element(:"geo:geo", [
      element(:"geo:format", data[:format])
    ])
  end

  @doc """
  Generate a mobile sitemap element
  """
  def mobile do
    element(:"mobile:mobile")
  end

  @doc """
  Generate a pagemap sitemap element
  """
  def pagemap(data) do
    element(
      :PageMap,
      Enum.map(data[:dataobjects] || [], fn obj ->
        element(
          :DataObject,
          %{type: obj[:type], id: obj[:id]},
          Enum.map(obj[:attributes] || [], fn attr ->
            element(:Attribute, %{name: attr[:name]}, attr[:value])
          end)
        )
      end)
    )
  end

  @doc """
  Generates a sitemap index element
  """

  def index(link, opts \\ []) do
    element(
      :sitemap,
      Helpers.eraser([
        element(
          :loc,
          if(opts[:host], do: Helpers.urljoin(link, opts[:host]), else: link)
        ),
        element(
          :lastmod,
          Keyword.get_lazy(opts, :lastmod, fn -> Helpers.iso8601() end)
        )
      ])
    )
  end

  @doc """
  Generate a video sitemap element
  """
  def videos(list, elements \\ [])
  def videos([], elements), do: elements

  def videos([{_, _} | _] = list, elements) do
    # Make sure keyword list
    videos([list], elements)
  end

  def videos([data | tail], elements) do
    elm =
      element(
        :"video:video",
        Helpers.eraser([
          element(:"video:title", data[:title]),
          element(:"video:description", data[:description]),
          if data[:player_loc] do
            attrs = %{allow_embed: Helpers.yes_no(data[:allow_embed?])}

            attrs =
              ifput(
                data[:autoplay?],
                attrs,
                &Map.put(&1, :autoplay, Helpers.autoplay(data[:autoplay?]))
              )

            element(:"video:player_loc", attrs, data[:player_loc])
          end,
          element(:"video:content_loc", data[:content_loc]),
          element(:"video:thumbnail_loc", data[:thumbnail_loc]),
          element(:"video:duration", data[:duration]),
          element(:"video:expiration_date", data[:expiration_date]),
          unless(is_nil(data[:gallery_loc]),
            do:
              element(
                :"video:gallery_loc",
                %{title: data[:gallery_title]},
                data[:gallery_loc]
              )
          ),
          unless(is_nil(data[:rating]),
            do: element(:"video:rating", data[:rating])
          ),
          unless(is_nil(data[:view_count]),
            do: element(:"video:view_count", data[:view_count])
          ),
          unless(is_nil(data[:expiration_date]),
            do:
              element(
                :"video:expiration_date",
                Helpers.iso8601(data[:expiration_date])
              )
          ),
          unless(is_nil(data[:publication_date]),
            do:
              element(
                :"video:publication_date",
                Helpers.iso8601(data[:publication_date])
              )
          ),
          unless(is_nil(data[:tags]),
            do: Enum.map(data[:tags] || [], &element(:"video:tag", &1))
          ),
          unless(is_nil(data[:tag]), do: element(:"video:tag", data[:tag])),
          unless(is_nil(data[:category]),
            do: element(:"video:category", data[:category])
          ),
          unless(is_nil(data[:family_friendly]),
            do:
              element(
                :"video:family_friendly",
                Helpers.yes_no(data[:family_friendly])
              )
          ),
          unless is_nil(data[:restriction]) do
            attrs = %{relationship: Helpers.allow_deny(data[:relationship?])}
            element(:"video:restriction", attrs, data[:restriction])
          end,
          unless is_nil(data[:price]) do
            attrs = %{}

            attrs =
              ifput(
                data[:price_currency],
                attrs,
                &Map.put(&1, :currency, data[:price_currency])
              )

            attrs =
              ifput(
                data[:price_type],
                attrs,
                &Map.put(&1, :type, data[:price_type])
              )

            attrs =
              ifput(
                data[:price_resolution],
                attrs,
                &Map.put(&1, :resolution, data[:price_resolution])
              )

            element(
              :"video:price",
              attrs,
              data[:price]
            )
          end,
          unless(is_nil(data[:requires_subscription?]),
            do:
              element(
                :"video:requires_subscription",
                Helpers.yes_no(data[:requires_subscription?])
              )
          ),
          unless is_nil(data[:uploader]) do
            attrs = %{}

            attrs =
              ifput(
                data[:uploader_info],
                attrs,
                &Map.put(&1, :info, data[:uploader_info])
              )

            element(:"video:uploader", attrs, data[:uploader])
          end,
          unless(is_nil(data[:price]),
            do: element(:"video:price", video_price_attrs(data), data[:price])
          ),
          unless(is_nil(data[:live?]),
            do: element(:"video:live", Helpers.yes_no(data[:live?]))
          ),
          unless(is_nil(data[:requires_subscription]),
            do:
              element(
                :"video:requires_subscription",
                Helpers.yes_no(data[:requires_subscription])
              )
          ),
          unless is_nil(data[:platform_list]) do
            attrs = %{}

            attrs =
              ifput(
                data[:platform_relationship?],
                attrs,
                &Map.put(
                  &1,
                  :relationship,
                  Helpers.yes_no(data[:platform_relationship?])
                )
              )

            element(:"video:platform", attrs, data[:platform_list])
          end,
          unless is_nil(data[:show_title]) do
            attrs = %{}

            attrs =
              ifput(
                data[:show_title],
                attrs,
                &Map.put(
                  &1,
                  :relationship,
                  Helpers.yes_no(data[:show_title])
                )
              )

            attrs =
              ifput(
                data[:show_video_type],
                attrs,
                &Map.put(
                  &1,
                  :video_type,
                  Helpers.yes_no(data[:show_video_type])
                )
              )

            attrs =
              ifput(
                data[:show_episode_title],
                attrs,
                &Map.put(
                  &1,
                  :episode_title,
                  Helpers.yes_no(data[:show_episode_title])
                )
              )

            attrs =
              ifput(
                data[:show_season_number],
                attrs,
                &Map.put(
                  &1,
                  :season_number,
                  Helpers.yes_no(data[:show_season_number])
                )
              )

            attrs =
              ifput(
                data[:show_episode_number],
                attrs,
                &Map.put(
                  &1,
                  :episode_number,
                  Helpers.yes_no(data[:show_episode_number])
                )
              )

            attrs =
              ifput(
                data[:show_premier_date],
                attrs,
                &Map.put(
                  &1,
                  :premier_date,
                  Helpers.yes_no(data[:show_premier_date])
                )
              )

            element(:"video:tvshow", attrs, data[:show_title])
          end
        ])
      )

    videos(tail, elements ++ [elm])
  end

  defp video_price_attrs(data) do
    attrs = %{}
    attrs = Map.put(attrs, :currency, data[:price_currency])

    attrs =
      ifput(data[:price_type], attrs, &Map.put(&1, :type, data[:price_type]))

    attrs =
      ifput(
        data[:price_type],
        attrs,
        &Map.put(&1, :resolution, data[:price_resolution])
      )

    attrs
  end

  def alternates(list, elements \\ [])
  def alternates([], elements), do: elements

  def alternates([{_, _} | _] = list, elements) do
    # Make sure keyword list
    alternates([list], elements)
  end

  def alternates([data | tail], elements) do
    rel = if data[:nofollow], do: "alternate nofollow", else: "alternate"

    attrs = %{rel: rel, href: data[:href]}
    attrs = Map.put(attrs, :hreflang, data[:lang])
    attrs = Map.put(attrs, :media, data[:media])

    alternates(tail, elements ++ [element(:"xhtml:link", attrs)])
  end

  defp ifput(bool, elements, fun) do
    if bool do
      fun.(elements)
    else
      elements
    end
  end

  defp append_last(elements, element) do
    combine = elem(elements, 2) ++ [element]

    elements
    |> Tuple.delete_at(2)
    |> Tuple.insert_at(2, combine)
  end
end
