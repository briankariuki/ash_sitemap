defmodule AshSitemap.Resource do
  use Spark.Dsl,
    default_extensions: [
      extensions: [AshSitemap.Resource.Dsl]
    ]
end
