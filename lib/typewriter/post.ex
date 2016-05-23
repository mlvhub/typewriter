defmodule Typewriter.Post do

  alias Typewriter.Yaml

  @derive [Poison.Encoder]
  defstruct slug: nil, title: nil, creation_date: nil, description: nil, content: nil, tags: [], sanitized_content: nil, author: nil

  # Agent API

  def start_link do
    Agent.start_link(fn -> [] end, name: __MODULE__)
  end

  def add(post) do
    Agent.update(__MODULE__, fn posts -> [post | posts] end)
  end

  def list do
    Agent.get(__MODULE__, &(&1))
  end

  # Markdown handling

  def compile(file_path) do
    post = %Typewriter.Post{
      slug: file_path |> Path.basename |> file_to_slug
    }

    file_path
    |> File.read!
    |> split
    |> extract(post)
  end

  defp file_to_slug(file) do
    String.replace(file, ~r/\.md$/, "")
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
      content: content,
      sanitized_content: HtmlSanitizeEx.strip_tags(content),
      tags: Yaml.get_tags(props),
    }
  end

end

defimpl Poison.Encoder, for: Typewriter.Post do
  def encode(%Typewriter.Post{title: title, sanitized_content: body, author: author}, options) do
    Poison.Encoder.Map.encode(%{title: title, body: body, author: author}, options)
  end
end
