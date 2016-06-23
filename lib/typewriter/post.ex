defmodule Typewriter.Post do

  alias Typewriter.Yaml

  @derive [Poison.Encoder]
  defstruct title: nil, creation_date: nil, description: nil, content: nil, tags: [], sanitized_content: nil, author_id: nil, cover_image: nil, slug: nil

  @reject_characters ["", " ", "-", ",", "."]

  # Agent API

  def start_link do
    Agent.start_link(fn -> [] end, name: __MODULE__)
  end

  def add(post) do
    Agent.get_and_update(__MODULE__, fn posts ->
      filtered_posts = posts |> Enum.filter(fn p -> p.title != post.title end)
      {post, [post | filtered_posts]}
    end)
  end

  def word_count(post) do
    post.sanitized_content
    |> String.split
    |> Enum.reject(fn str -> Enum.member?(@reject_characters, str) end)
    |> Enum.count
  end

  def recommend(post, amount \\ 5) do
    list
    |> Enum.reject(fn p -> p.slug == post.slug end)
    |> Enum.map(fn p ->
      intersection = MapSet.intersection(MapSet.new(p.tags), MapSet.new(post.tags))
      {p, MapSet.size(intersection)}
    end)
    |> Enum.sort(fn {_, int1}, {_, int2} -> int1 > int2 end)
    |> Enum.take(amount)
    |> Enum.map(fn {p, _} -> p end)
  end

  def get_by_title(post_title) do
    list
    |> Enum.filter(fn post -> post.title == post_title end)
  end

  def list do
    Agent.get(__MODULE__, &(&1))
  end

  def ordered_list do
    list
    |> Enum.sort(fn a, b ->
      d1 = Timex.parse!(a.creation_date, "{ISOdate}")
      d2 = Timex.parse!(b.creation_date, "{ISOdate}")
      Timex.compare(d1, d2) > 0
    end)
  end

  def clear do
    Agent.update(__MODULE__, fn _ -> [] end)
  end

  # Markdown handling

  def compile(file_path) do
    post = %Typewriter.Post{
      slug: Path.basename(file_path, Path.extname(file_path))
    }

    file_path
    |> File.read!
    |> split
    |> extract(post)
    |> add
  end

  defp split(data) do
    [frontmatter, markdown] = String.split(data, ~r/\n-{3,}\n/, parts: 2)
    {Yaml.parse(frontmatter), Earmark.to_html(markdown)}
  end

  defp extract({props, content}, post) do
    %{post |
      title: Yaml.get_prop(props, "title"),
      creation_date: Yaml.get_prop(props, "creation_date"),
      description: Yaml.get_prop(props, "description"),
      author_id: Yaml.get_prop(props, "author_id"),
      content: content,
      sanitized_content: content |> String.replace("\n", " ") |> HtmlSanitizeEx.strip_tags,
      cover_image: Yaml.get_prop(props, "cover_image"),
      tags: Yaml.get_list(props, "tags"),
    }
  end

end

defimpl Poison.Encoder, for: Typewriter.Post do
  def encode(%Typewriter.Post{title: title, sanitized_content: body, author_id: author_id, tags: tags}, options) do
    Poison.Encoder.Map.encode(%{title: title, body: body, author_id: author_id, tags: tags}, options)
  end
end
