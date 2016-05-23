defmodule Typewriter.Config do

  alias Typewriter.Yaml

  defstruct tags: [], post_template: nil, posts_template: nil, posts_dir: nil, layout: nil

  @file_path "config.yaml"

  # Agent API

  def start_link do
    Agent.start_link(fn -> %Typewriter.Config{} end, name: __MODULE__)
  end

  def init(root_dir) do
    yaml = Yaml.compile(Path.join([root_dir, @file_path]))
    config = %Typewriter.Config{
      tags: Yaml.get_tags(yaml),
      posts_template: Yaml.get_prop(yaml, "posts_template"),
      layout: Yaml.get_prop(yaml, "layout"),
      post_template: Yaml.get_prop(yaml, "post_template"),
      posts_dir: Yaml.get_prop(yaml, "posts_dir"),
    }
    Agent.update(__MODULE__, fn _ -> config end)
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