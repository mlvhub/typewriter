defmodule Typewriter.ConfigTest do
  use ExUnit.Case
  doctest Typewriter.Config

  alias Typewriter.Config

  @root_dir "test/sample_files"
  @empty_config "test/sample_files/empty_config"

  setup do
    Config.start_link
    Config.init(@root_dir)
    :ok
  end

  test "should load the yaml config correctly" do
    config = Config.get
    assert config.tags == ["swift", "tdd", "ios", "elixir", "phoenix"]
    assert config.post_template == "templates/post.html.eex"
    assert config.posts_template == "templates/posts.html.eex"
    assert config.author_template == "templates/author.html.eex"
    assert config.authors_template == "templates/authors.html.eex"
    assert config.posts_dir == "posts"
    assert config.authors_dir == "authors"
    assert config.ignored_dirs == [".git"]
    assert config.ignored_files == ["README.md"]
    assert config.layout_template == "templates/layout.html.eex"
  end

  test "updating a value from the config should work" do
    new_value = %{posts_dir: "new_posts_dir"}
    config = Config.update(new_value)
    assert config.tags == ["swift", "tdd", "ios", "elixir", "phoenix"]
    assert config.post_template == "templates/post.html.eex"
    assert config.posts_template == "templates/posts.html.eex"
    assert config.author_template == "templates/author.html.eex"
    assert config.authors_template == "templates/authors.html.eex"
    assert config.posts_dir == "new_posts_dir"
    assert config.authors_dir == "authors"
    assert config.ignored_dirs == [".git"]
    assert config.ignored_files == ["README.md"]
    assert config.layout_template == "templates/layout.html.eex"
  end

  test "a config should have defaults values" do
    config = Config.init(@empty_config)

    assert config.posts_template == "index.html.eex"
    assert config.tags == []
    assert config.post_template == "templates/post.html.eex"
    assert config.author_template == "templates/author.html.eex"
    assert config.authors_template == "templates/authors.html.eex"
    assert config.posts_dir == "posts"
    assert config.authors_dir == "authors"
    assert config.ignored_dirs == []
    assert config.ignored_files == []
    assert config.layout_template == "templates/layout.html.eex"
  end
end
