defmodule Mix.Tasks.SeedArticles do
  @moduledoc """
  Seed a couple of demo artricles.
  """

  use Mix.Task
  alias Example.Article

  def run(_args) do
    Mix.Task.run("app.start", [])
    generate_articles()

    # Print a list of articles
    Article
    |> Ash.Query.for_read(:read)
    |> Ash.read!(page: [limit: 10])
    |> then(fn offset -> offset.results end)
    |> print_table()
  end

  def generate_articles() do
    IO.puts("Seeding demo data...")

    Task.async_stream(
      0..100_000,
      fn _ -> generate_random_article() end,
      max_concurrency: System.schedulers_online() * 2,
      ordered: false,
      timeout: :infinity
    )
    |> Stream.map(fn
      {:ok, article} -> article
      {:error, _} -> nil
    end)
    |> Stream.reject(&is_nil/1)
    |> Stream.chunk_every(1000)
    |> Stream.each(&create_articles/1)
    |> Stream.run()

    IO.puts("Seeding demo data... done")
  end

  defp create_articles(articles) do
    Ash.bulk_create!(articles, Article, :create, authorize?: false)
  end

  defp random_first_name do
    [
      "Olivia",
      "Emma",
      "Ava",
      "Sophia",
      "Isabella",
      "Charlotte",
      "Amelia",
      "Mia",
      "Harper",
      "Evelyn",
      "Abigail",
      "Emily",
      "Ella",
      "Elizabeth",
      "Camila",
      "Luna",
      "Sofia",
      "Avery",
      "Mila",
      "Aria",
      "Scarlett",
      "Penelope",
      "Liam",
      "Noah",
      "Oliver",
      "Elijah",
      "William",
      "James",
      "Benjamin",
      "Lucas",
      "Henry",
      "Alexander",
      "Mason",
      "Michael",
      "Ethan",
      "Daniel",
      "Jacob",
      "Logan",
      "Jackson",
      "Levi",
      "Sebastian",
      "Mateo",
      "Jack",
      "Owen"
    ]
    |> Enum.random()
  end

  defp print_table(articles) do
    IO.puts("|--------|----------------------------------------------|")
    IO.puts("| Title  | Description                                  |")
    IO.puts("|--------|----------------------------------------------|")

    Enum.each(articles, fn article ->
      description = "#{article.description}"

      IO.puts(
        "| #{article.title |> String.pad_trailing(6)} | #{String.pad_trailing(description, 22)} |"
      )
    end)

    IO.puts("|--------|----------------------------------------------|")
  end

  defp generate_random_article() do
    first_name = random_first_name()
    second_name = random_first_name()

    %{
      title: Example.Lorem.words(rand_range(3, 6)),
      description: Example.Lorem.sentence(),
      content: Example.Lorem.paragraphs(rand_range(3, 5)),
      author: "#{first_name} #{second_name}"
    }
  end

  defp rand_range(min, max) do
    :rand.uniform(max - min + 1) + min - 1
  end
end
