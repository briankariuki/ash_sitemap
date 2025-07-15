defmodule AshSitemap.Helpers do
  @moduledoc """
  Useful helper functions
  """
  @progress_bar_size 100
  @complete_character "█"
  @incomplete_character "░"

  def iso8601(yy, mm, dd, hh, mi, ss) do
    "~4.10.0B-~2.10.0B-~2.10.0BT~2.10.0B:~2.10.0B:~2.10.0BZ"
    |> :io_lib.format([yy, mm, dd, hh, mi, ss])
    |> IO.iodata_to_binary()
  end

  def iso8601 do
    {{yy, mm, dd}, {hh, mi, ss}} = :calendar.universal_time()
    iso8601(yy, mm, dd, hh, mi, ss)
  end

  def iso8601({{yy, mm, dd}, {hh, mi, ss}}) do
    iso8601(yy, mm, dd, hh, mi, ss)
  end

  if Code.ensure_loaded?(NaiveDateTime) do
    def iso8601(%NaiveDateTime{} = dt) do
      dt
      |> NaiveDateTime.to_erl()
      |> iso8601()
    end

    def iso8601(%DateTime{} = dt) do
      DateTime.to_iso8601(dt)
    end
  end

  def iso8601(%Date{} = dt) do
    Date.to_iso8601(dt)
  end

  if Code.ensure_loaded?(Ecto.DateTime) do
    def iso8601(%Ecto.DateTime{} = dt) do
      dt
      |> Ecto.DateTime.to_erl()
      |> iso8601()
    end
  end

  if Code.ensure_loaded?(Ecto.Date) do
    def iso8601(%Ecto.Date{} = dt) do
      Ecto.Date.to_iso8601(dt)
    end
  end

  def iso8601(dt), do: dt

  def eraser(elements) do
    Enum.filter(elements, fn elm ->
      case elm do
        e when is_list(e) -> eraser(e)
        nil -> false
        _ -> !!elem(elm, 2)
      end
    end)
  end

  def yes_no(bool) do
    if bool == false, do: "no", else: "yes"
  end

  def allow_deny(bool) do
    if bool == false, do: "deny", else: "allow"
  end

  def autoplay(bool) do
    if bool, do: "ap=1", else: "ap=0"
  end

  def getenv(key) do
    x = System.get_env(key)

    cond do
      x == "false" ->
        false

      x == "true" ->
        true

      is_numeric(x) ->
        {num, _} = Integer.parse(x)
        num

      true ->
        x
    end
  end

  def nil_or(opts), do: nil_or(opts, "")
  def nil_or([], value), do: value

  def nil_or([h | t], _value) do
    case h do
      v when is_nil(v) -> nil_or(t, "")
      v -> nil_or([], v)
    end
  end

  def is_numeric(str) when is_nil(str), do: false

  def is_numeric(str) do
    case Float.parse(str) do
      {_num, ""} -> true
      {_num, _r} -> false
      :error -> false
    end
  end

  def urljoin(src, dest) do
    {s, d} = {URI.parse(src), URI.parse(dest)}

    to_string(
      struct(s,
        host: d.host || s.host,
        path: d.path || s.path,
        port: d.port || s.port,
        query: d.query || s.query,
        scheme: d.scheme || s.scheme,
        userinfo: d.userinfo || s.userinfo,
        fragment: d.fragment || s.fragment
        # authority: d.authority || s.authority
      )
    )
  end

  @doc """
  ## Parameters
  number - any integer/float
  divisor - what to divide by

  ## Returns
  {quotient, remainder}

  ## Example

    iex(6)> Data.divmod(12, 2)
    {6, 0}
    iex(7)> Data.divmod(12, 3)
    {4, 0}
    iex(8)> Data.divmod(12, 4)
    {3, 0}
    iex(9)> Data.divmod(12, 4.5)
    {2, 3.0}

  """
  def divmod(number, divisor) do
    result = number / divisor
    quotient = result |> Kernel.floor()
    remainder = number - quotient * divisor
    {quotient, remainder}
  end

  @doc """
  Renders a progress bar
  """
  def progress_bar(count, total, prefix) do
    format = [
      left: [
        IO.ANSI.light_magenta(),
        "GENERATING[#{prefix}]:",
        IO.ANSI.reset(),
        " |"
      ],
      bar_color: [IO.ANSI.cyan()],
      blank_color: [IO.ANSI.white()],
      bar: @complete_character,
      blank: @incomplete_character,
      suffix: :count,
      width: @progress_bar_size
    ]

    ProgressBar.render(count, total, format)
  end

  @doc """
  Gets the rootpath in relation to the current module
  """
  def root_path do
    Mix.Project.get().module_info()[:compile][:source]
    |> Path.dirname()
  end

  @doc """
  Returns the number of sitemap files to generate
  """
  def sitemap_files_count(count, limit) when count < limit do
    1
  end

  def sitemap_files_count(count, limit) do
    {quotient, remainder} = AshSitemap.Helpers.divmod(count, limit)

    if remainder > 0 do
      quotient + 1
    else
      quotient
    end
  end

  @doc """
  Returns the schema for the sitemap.
  """
  def schemas do
    %{
      geo: "http://www.google.com/geo/schemas/sitemap/1.0",
      news: "http://www.google.com/schemas/sitemap-news/0.9",
      image: "http://www.google.com/schemas/sitemap-image/1.1",
      video: "http://www.google.com/schemas/sitemap-video/1.1",
      mobile: "http://www.google.com/schemas/sitemap-mobile/1.0",
      pagemap: "http://www.google.com/schemas/sitemap-pagemap/1.0"
    }
  end

  @doc """
  Xml header for the sitemap.
  """
  def xml_header do
    """
    <?xml version="1.0" encoding="UTF-8"?>
    <urlset
      xmlns:xsi='http://www.w3.org/2001/XMLSchema-instance'
      xsi:schemaLocation="http://www.sitemaps.org/schemas/sitemap/0.9
        http://www.sitemaps.org/schemas/sitemap/0.9/sitemap.xsd"
      xmlns='http://www.sitemaps.org/schemas/sitemap/0.9'
      xmlns:geo='http://www.google.com/geo/schemas/sitemap/1.0'
      xmlns:news='http://www.google.com/schemas/sitemap-news/0.9'
      xmlns:image='http://www.google.com/schemas/sitemap-image/1.1'
      xmlns:video='http://www.google.com/schemas/sitemap-video/1.1'
      xmlns:mobile='http://www.google.com/schemas/sitemap-mobile/1.0'
      xmlns:pagemap='http://www.google.com/schemas/sitemap-pagemap/1.0'
      xmlns:xhtml='http://www.w3.org/1999/xhtml'
    >
    """
  end

  @doc """
  Xml footer for the sitemap.
  """
  def xml_footer do
    "</urlset>"
  end

  @doc """
  Xml index header for the sitemap.
  """
  def xml_index_header do
    """
    <?xml version="1.0" encoding="UTF-8"?>
    <sitemapindex
      xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
      xsi:schemaLocation="http://www.sitemaps.org/schemas/sitemap/0.9
        http://www.sitemaps.org/schemas/sitemap/0.9/siteindex.xsd"
      xmlns="http://www.sitemaps.org/schemas/sitemap/0.9"
    >
    """
  end

  @doc """
  Xml index footer for the sitemap.
  """
  def xml_index_footer do
    "</sitemapindex>"
  end
end
