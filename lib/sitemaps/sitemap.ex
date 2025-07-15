defmodule AshSitemap.Sitemaps.Sitemap do
  defstruct [
    :name,
    :path,
    :priority,
    read_action: nil,
    news: nil,
    video: nil,
    image: nil
  ]

  def build(record, sitemap) do
    callback_fn = fn
      x when is_function(x) -> x.(record)
      x -> x
    end

    news_fn = fn
      x when is_function(x) ->
        x.(record)

      x ->
        to_item_callback(record, x)
    end

    video_fn = fn
      x when is_function(x) ->
        x.(record)

      x when is_list(x) ->
        Enum.map(x, fn v -> to_item_callback(record, v) end)

      x ->
        to_item_callback(record, x)
    end

    image_fn = fn
      x when is_function(x) ->
        x.(record)

      x when is_list(x) ->
        Enum.map(x, fn v -> to_item_callback(record, v) end)

      x ->
        to_item_callback(record, x)
    end

    path = callback_fn.(sitemap.path)
    priority = callback_fn.(sitemap.priority)
    read_action = callback_fn.(sitemap.read_action)
    news = news_fn.(sitemap.news)
    video = video_fn.(sitemap.video)
    image = image_fn.(sitemap.image)

    %__MODULE__{
      name: sitemap.name,
      path: path,
      news: news,
      video: video,
      image: image,
      read_action: read_action,
      priority: priority
    }
  end

  defp to_item_callback(record, value) do
    case value do
      x when is_function(x) ->
        x.(record)

      x when is_atom(x) ->
        record |> Map.get(x)

      x when is_struct(x) ->
        x
        |> Map.from_struct()
        |> Enum.map(fn {k, v} -> {k, to_item_callback(record, v)} end)

      x ->
        x
    end
  end
end
