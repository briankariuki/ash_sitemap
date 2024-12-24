defprotocol AshSitemap.Generate do
  @spec generate(t) :: [String.t()]
  def generate(value)
end
