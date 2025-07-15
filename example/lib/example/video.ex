defmodule Example.Video do
  @moduledoc """
  A resource for managing news videos.
  """
  use Ash.Resource,
    domain: Example.News,
    validate_domain_inclusion?: false,
    data_layer: AshSqlite.DataLayer,
    extensions: [AshSitemap.Resource]

  sqlite do
    table "videos"
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

  # sitemap do
  #   host "https://example.com"
  #   compress true
  #   read_action :read
  #   file_path "/priv/sitemap.xml"

  #   url("index.html",
  #     priority: 0.5,
  #     news: [
  #       title: :title,
  #       publication_name: "Example News",
  #       publication_language: "en",
  #       publication_date: "2021-01-01",
  #       keywords: ["hello", "world"]
  #     ]
  #   )
  # end

  sitemaps do
    sitemap :videos do
      path "videos/index.html"
      priority 0.5
    end
  end
end
