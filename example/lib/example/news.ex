defmodule Example.News do
  @moduledoc """
  Example news domain
  """
  use Ash.Domain

  resources do
    resource Example.Article
    resource Example.Video
  end
end
