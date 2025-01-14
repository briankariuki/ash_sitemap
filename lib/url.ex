defmodule AshSitemap.Url do
  alias AshSitemap.Build

  defstruct [
    :host,
    :file_path,
    :read_action,
    :path,
    :priority,
    news: nil,
    video: nil,
    image: nil
  ]

  def map(record, url, opts \\ []) do
    host = Keyword.get(opts, :host, "")
    read_action = Keyword.get(opts, :read_action, "")
    file_path = Keyword.get(opts, :file_path, "")

    callback_fn = fn
      x when is_function(x) -> x.(record)
      x -> x
    end

    news_fn = fn
      x when is_function(x) ->
        x.(record)

      x when is_list(x) ->
        Enum.map(x, fn {k, v} -> {k, to_news(record, v)} end)

      x ->
        x
    end

    video_fn = fn
      x when is_function(x) ->
        x.(record)

      x when is_list(x) ->
        Enum.map(x, fn {k, v} -> {k, to_video(record, v)} end)

      x ->
        x
    end

    image_fn = fn
      x when is_function(x) ->
        x.(record)

      x when is_list(x) ->
        Enum.map(x, fn {k, v} -> {k, to_image(record, v)} end)

      x ->
        x
    end

    path = callback_fn.(url.path)
    priority = callback_fn.(url.priority)
    news = news_fn.(url.news)
    video = video_fn.(url.video)
    image = image_fn.(url.image)

    %AshSitemap.Url{
      host: host,
      path: path,
      news: news,
      video: video,
      image: image,
      read_action: read_action,
      file_path: file_path,
      priority: priority
    }
  end

  def to_news(record, value) do
    case value do
      x when is_function(x) ->
        x.(record)

      x when is_atom(x) ->
        record |> Map.get(x)

      x ->
        x
    end
  end

  def to_video(record, value) do
    case value do
      x when is_function(x) ->
        x.(record)

      x when is_atom(x) ->
        record |> Map.get(x)

      x ->
        x
    end
  end

  def to_image(record, value) do
    case value do
      x when is_function(x) ->
        x.(record)

      x when is_atom(x) ->
        record |> Map.get(x)

      x ->
        x
    end
  end

  def to_xml(url) do
    Build.to_xml(url)
  end
end
