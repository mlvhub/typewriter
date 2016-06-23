defmodule Typewriter.PostTest do
  use ExUnit.Case
  doctest Typewriter.Post

  alias Typewriter.Post

  @path1 "test/sample_files/first-post.md"
  @author_path "test/sample_files/authors/miguel-lopez.yaml"

  setup do
    Post.start_link
    :ok
  end

  test "should add and clear posts correctly" do
    Post.compile(@path1)
    assert Post.list |> Enum.count == 1

    Post.clear
    assert Post.list |> Enum.count == 0
  end

  test "should compile a blog post correctly" do
    post = Post.compile(@path1)
    assert post.title == "First post"
    assert post.description == "The first post is about one topic."
    assert post.tags == ["swift", "ios", "tdd"]
    assert post.content != nil
    assert post.sanitized_content != nil
    assert post.creation_date == "2016-04-24"
    assert post.author_id == "mlopez150693"
    assert post.cover_image == "images/dummy.png"
  end

  test "should not add repeated posts" do
    Post.compile(@path1)
    Post.compile(@path1)

    assert Post.list |> Enum.count == 1
  end

  test "should get author info correctly" do
    post = Post.compile(@path1)
    Typewriter.Author.start_link
    Typewriter.Author.compile(@author_path)

    author = Post.author_info(post)
    assert author.name == "Miguel López Valenciano"
  end

  test "should not get author info if the author is not loaded or non existent" do
    post = Post.compile(@path1)
    Typewriter.Author.start_link

    author = Post.author_info(post)
    assert author == nil
  end

  test "should count the post's word average correctly" do
    post = Post.compile(@path1)

    assert Post.word_count(post) > 0
  end
end
