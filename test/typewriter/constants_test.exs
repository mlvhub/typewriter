defmodule Typewriter.ConstantsTest do
  use ExUnit.Case
  doctest Typewriter.Constants

  alias Typewriter.Constants

  @root_dir "test/sample_files"

  setup do
    Constants.start_link
    Constants.init(@root_dir)

    :ok
  end

  test "should compile the constants correctly" do
    constants = Constants.get
    assert constants["home_path"] == "/"
    assert constants["posts_path"] == "/posts/<%= index %>/"
  end

  test "should clear correctly" do
    Constants.clear
    constants = Constants.get
    assert constants == %{}
  end

end
