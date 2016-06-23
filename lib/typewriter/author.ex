defmodule Typewriter.Author do

  alias Typewriter.Yaml

  @derive [Poison.Encoder]
  defstruct author_id: nil, name: nil, bio: nil, linked_in: nil, twitter: nil, github: nil, profile_picture: nil

  # Agent API

  def start_link do
    Agent.start_link(fn -> [] end, name: __MODULE__)
  end

  def add(author) do
    Agent.get_and_update(__MODULE__, fn authors ->
      filtered_authors = authors |> Enum.filter(fn a -> a.author_id != author.author_id end)
      {author, [author | filtered_authors]}
    end)
  end

  def by_id(author_id) do
    list
    |> Enum.find(fn a -> a.author_id == author_id end)
  end

  def list do
    Agent.get(__MODULE__, &(&1))
  end

  def clear do
    Agent.update(__MODULE__, fn _ -> [] end)
  end

  # Markdown handling

  def compile(file_path) do
    author = %Typewriter.Author{}

    file_path
    |> Yaml.compile
    |> extract(author)
    |> add
  end

  defp extract(props, author) do
    %{author |
      author_id: Yaml.get_prop(props, "author_id"),
      name: Yaml.get_prop(props, "name"),
      bio: Yaml.get_prop(props, "bio"),
      linked_in: Yaml.get_prop(props, "linked_in"),
      twitter: Yaml.get_prop(props, "twitter"),
      github: Yaml.get_prop(props, "github"),
      profile_picture: Yaml.get_prop(props, "profile_picture"),
    }
  end

end
