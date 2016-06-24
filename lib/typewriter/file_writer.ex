defmodule Typewriter.FileWriter do

  def write_plural_file(build_path, root_dir, template_file, assigns) do
    config = Typewriter.Config.get
    contents = EEx.eval_file(Path.join([root_dir, template_file]), assigns: assigns)
    new_path = Path.join([build_path, Path.basename(root_dir), Path.basename(template_file, Path.extname(template_file))])
    File.write!(new_path, contents)
  end

  def write_author_file(root_dir, full_path, new_build_full_path) do
    config = Typewriter.Config.get
    Task.async(fn ->
      author = Typewriter.Author.compile(full_path)

      author_content = EEx.eval_file(Path.join([root_dir, config.author_template]), assigns: [author: author])

      # Evaluate the layout template, by giving it the evaluated author template
      layout_content = EEx.eval_file(Path.join([root_dir, config.layout_template]), assigns: [content: author_content])

      new_html_path = new_singular_path(new_build_full_path, ".html")

      File.write!(new_html_path, layout_content)

      author
    end)
  end

  def write_post_file(root_dir, full_path, new_build_full_path) do
    config = Typewriter.Config.get
    Task.async(fn ->
      post = Typewriter.Post.compile(full_path, root_dir)

      post_content = EEx.eval_file(Path.join([root_dir, config.post_template]), assigns: [post: post, recommended_posts: Typewriter.Post.recommend(post)])

      # Evaluate the layout template, by giving it the evaluated post template
      layout_content = EEx.eval_file(Path.join([root_dir, config.layout_template]), assigns: [content: post_content])

      json_content = Poison.encode!(post)

      new_html_path = new_singular_path(new_build_full_path, ".html")
      new_json_path = new_singular_path(new_build_full_path, ".json")

      File.write!(new_html_path, layout_content)
      File.write!(new_json_path, json_content)

      post
    end)
  end

  def copy_dir_and_get_valid_children(full_path, new_build_full_path, ignored_dirs) do
    File.mkdir!(new_build_full_path)
    # prepare dir children and their paths
    full_path
    |> File.ls!
    |> Enum.filter(fn f -> !Enum.member?(ignored_dirs, f) end)
    |> Enum.map(fn f -> Path.join([full_path, f]) end)
  end

  def copy_file(full_path, new_build_full_path) do
    Task.async(fn ->
      File.copy!(full_path, new_build_full_path)
    end)
  end

  defp new_singular_path(new_build_full_path, ext) do
    Path.join(Path.dirname(new_build_full_path), Path.basename(new_build_full_path, Path.extname(new_build_full_path)) <> ext)
  end
end
