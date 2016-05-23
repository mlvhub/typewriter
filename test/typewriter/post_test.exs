defmodule Typewriter.PostTest do
  use ExUnit.Case
  doctest Typewriter.Post

  alias Typewriter.Post

  @path1 "test/sample_files/first-post.md"

  test "should convert a filepath to slug correctly" do
    post = Post.compile(@path1)
    assert post.title == "First post"
    assert post.description == "The first post is about one topic."
    assert post.tags == ["swift", "ios", "tdd"]
    assert post.content != nil
    assert post.creation_date != nil
  end
end
