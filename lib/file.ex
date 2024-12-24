defmodule AshSitemap.File do
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
