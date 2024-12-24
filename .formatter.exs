spark_locals_without_parens = [
  pick: 1,
  merge: 1,
  customize: 1,
  host: 1,
  compress: 1,
  url: 1,
  news: 1,
  file_path: 1,
  read_action: 1,
  path: 1
]

[
  import_deps: [:ash],
  plugins: [Spark.Formatter],
  inputs: ["{mix,.formatter}.exs", "{config,lib,test}/**/*.{ex,exs}"],
  line_length: 80,
  trailing_comma: true,
  local_pipe_with_parens: true,
  single_clause_on_do: true,
  locals_without_parens: spark_locals_without_parens,
  export: [locals_without_parens: spark_locals_without_parens]
]
