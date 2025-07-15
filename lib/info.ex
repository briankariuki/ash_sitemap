defmodule AshSitemap.Resource.Info do
  use Spark.InfoGenerator,
    extension: AshSitemap.Resource.Dsl,
    sections: [:sitemaps]
end
