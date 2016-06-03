defmodule Typewriter.FileWriterTest do
  use ExUnit.Case
  doctest Typewriter.FileWriter

  alias Typewriter.FileWriter

  @root "sample_project"
  @build "sample_project/typewriter_build"
  @posts [%Typewriter.Post{author: nil,
  content: "<p>This post is also written in <strong>Markdown</strong>.</p>\n<p>A link: <a href=\"http://www.sebastianseilund.com\">Sebastian Seilund</a></p>\n<p><img src=\"/images/phoenix.png\" alt=\"phoenix\"/></p>\n",
  cover_image: nil, creation_date: nil, description: nil,
  sanitized_content: "This post is also written in Markdown.A link: Sebastian Seilund",
  tags: [], title: "Second post"},
 %Typewriter.Post{author: nil,
  content: "<p>This post is written in <strong>Markdown</strong>.</p>\n<h2>A header2 is good</h2>\n<p>Lists are nice, too:</p>\n<ul>\n<li>Apples\n</li>\n<li>Bananas\n</li>\n<li>Pears\n</li>\n</ul>\n<p><a href=\"/\" title=\"Home\">Home</a></p>\n",
  cover_image: nil, creation_date: "2016-04-24",
  description: "The first post is about one topic.",
  sanitized_content: "This post is written in Markdown.A header2 is goodLists are nice, too:Apples\nBananas\nPears\nHome",
  tags: ["swift", "ios", "tdd"], title: "First post"}]
  @path1 "test/sample_files/first-post.md"

  setup do
    Typewriter.Config.init(@root)
    config = Typewriter.Config.get

    on_exit fn ->
      Agent.stop(Typewriter.Config)
      File.rm_rf!(String.replace(@path1, ".md", ".html"))
      File.rm_rf!(String.replace(@path1, ".md", ".json"))
    end

    {:ok, config: config}
  end

  @tag :skip
  test "should write posts file correctly", %{config: config} do
    FileWriter.write_posts_file(@build, @root, @posts)

    template_file = Path.join([@build, @root, Path.basename(config.posts_template, ".eex")])
    assert File.exists?(template_file)
  end

  test "should write all post files correctly" do
    task = FileWriter.write_post_files(@root, @path1, @path1)
    Task.await(task)
    assert File.exists?(String.replace(@path1, ".md", ".html"))
    assert File.exists?(String.replace(@path1, ".md", ".json"))
  end
end
