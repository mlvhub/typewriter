defmodule Typewriter.YamlTest do
  use ExUnit.Case
  doctest Typewriter.Yaml

  alias Typewriter.Yaml

  @path1 "test/sample_files/values.yaml"

  test "should load the yaml values correctly" do
    yaml = Yaml.compile(@path1)
    assert Yaml.get_list(yaml, "tags") == ["swift", "ios", "tdd", "elixir", "phoenix"]
  end
end
