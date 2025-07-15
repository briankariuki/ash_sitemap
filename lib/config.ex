defmodule AshSitemap.Config do
  @moduledoc """
  Configuration options for `AshSitemap`
  """

  @urls_limit 50000
  @query_limit 250
  @default_path "priv/static/sitemaps"

  def hostname do
    Application.get_env(:ash_sitemap, :hostname)
    |> case do
      url when is_binary(url) and url != "" ->
        url

      no_url ->
        raise ArgumentError,
          message:
            ~s|Please set config variable `config :ash_sitemap, hostname: "https://..."`, got: `#{inspect(no_url)}`|
    end
  end

  def compress do
    Application.get_env(:ash_sitemap, :url, true)
  end

  def path do
    Application.get_env(:ash_sitemap, :path, @default_path)
  end

  def query_limit do
    Application.get_env(:ash_sitemap, :query_limit, @query_limit)
  end

  def urls_limit do
    Application.get_env(:ash_sitemap, :urls_limit, @urls_limit)
  end
end
