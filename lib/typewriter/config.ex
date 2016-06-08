defmodule Typewriter.Config do

  alias Typewriter.Yaml

  defstruct tags: [], post_template: "templates/post.html.eex", posts_template: "templates/posts.html.eex", posts_dir: "posts", layout_template: "templates/layout.html.eex", ignored_dirs: [], ignored_files: []

  @file_path "config.yaml"

  # Agent API

  def start_link do
    Agent.start_link(fn -> %Typewriter.Config{} end, name: __MODULE__)
  end

  def init(root_dir) do
    yaml = Yaml.compile(Path.join([root_dir, @file_path]))
    config = %Typewriter.Config{
      tags: Yaml.get_list(yaml, "tags"),
      ignored_files: Yaml.get_list(yaml, "ignored_files"),
      ignored_dirs: Yaml.get_list(yaml, "ignored_dirs"),
      posts_template: Yaml.get_prop(yaml, "posts_template"),
      layout_template: Yaml.get_prop(yaml, "layout_template"),
      post_template: Yaml.get_prop(yaml, "post_template"),
      posts_dir: Yaml.get_prop(yaml, "posts_dir"),
    }

    config
    |> Map.from_struct
    |> Enum.reject(fn {_, v} -> v == nil end)
    |> Enum.into(%{})
    |> update
  end

  def get do
    Agent.get(__MODULE__, &(&1))
  end

  def update(new_config) do
    Agent.update(__MODULE__, fn stored_config ->
      Map.merge(stored_config, new_config)
    end)
    get
  end

end
