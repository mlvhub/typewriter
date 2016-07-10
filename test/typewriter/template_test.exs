defmodule Typewriter.TemplateTest do
  use ExUnit.Case
  doctest Typewriter.Template

  alias Typewriter.Template

  @path "test/sample_files/post.html.eex"

  test "constants are loaded correctly in template files" do
    Template.eval(@path, [assigns: [name: "Name"]], %{"post_url": "/post/1/"})
  end

  test "can retrieve a template's file name correctly" do
    assert Template.file_name("index.html.eex") == "index"
  end
end
