defmodule Example.Article do
  @moduledoc """
  A resource for managing news articles.
  """
  use Ash.Resource,
    domain: Example.News,
    validate_domain_inclusion?: false,
    data_layer: AshSqlite.DataLayer,
    extensions: [AshSitemap.Resource]

  sqlite do
    table "articles"
    repo Example.Repo
  end

  attributes do
    uuid_primary_key :id, writable?: true
    attribute :title, :string, public?: true
    attribute :description, :string, public?: true
    attribute :content, :string, public?: true
    attribute :author, :string, public?: true
    create_timestamp :created_at, public?: true
    update_timestamp :updated_at, public?: true
  end

  actions do
    defaults create: :*, update: :*

    read :read do
      primary? true

      prepare build(sort: [created_at: :asc])
    end
  end

  sitemaps do
    sitemap :articles do
      path "index.html"
      priority 0.5

      news do
        title :title
        publication_name "Example News"
        publication_language "en"
        publication_date "2021-01-01"
      end

      image do
        loc "image.jpg"
      end

      image do
        loc "image2.jpg"
      end
    end
  end
end
