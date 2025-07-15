defmodule AshSitemap.Resource.Info do
  use Spark.InfoGenerator,
    extension: AshSitemap.Resource,
    sections: [:sitemaps]
end
