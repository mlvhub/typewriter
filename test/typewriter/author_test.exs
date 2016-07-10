defmodule Typewriter.AuthorTest do
  use ExUnit.Case
  doctest Typewriter.Author

  alias Typewriter.Author

  @path1 "test/sample_files/authors/miguel-lopez.yaml"

  setup do
    Author.start_link

    on_exit fn ->
      Author.clear
    end
    
    :ok
  end

  test "should add and clear authors correctly" do
    Author.compile(@path1)
    assert Author.list |> Enum.count == 1

    Author.clear
    assert Author.list |> Enum.count == 0
  end

  test "should compile an author correctly" do
    author = Author.compile(@path1)
    assert author.slug == "miguel-lopez"
    assert author.author_id == "mlopez150693"
    assert author.name == "Miguel López Valenciano"
    assert author.bio != nil
    assert author.linked_in == "https://cr.linkedin.com/in/mlopezvalenciano"
    assert author.twitter == "https://twitter.com/mig_lv"
    assert author.github == "https://github.com/mlvhub"
    assert author.profile_picture == "images/picture.png"
  end

  test "should find authors by id correctly" do
    author = Author.compile(@path1)
    assert Author.by_id(author.author_id) != nil
  end

  test "should not find authors by id with invalid ids" do
    assert Author.by_id("no id") == nil
  end

  test "should find an author by its filepath" do
    Author.compile(@path1)
    assert Author.by_filepath(@path1) != nil
  end

  test "should not find an author by its filepath if it doesn't exist" do
    Author.clear
    assert Author.by_filepath(@path1) == nil
  end

  test "should not add repeated authors" do
    Author.compile(@path1)
    Author.compile(@path1)

    # TODO: Verify add is only called once

    assert Author.list |> Enum.count == 1
  end

end
