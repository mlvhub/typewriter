defmodule Typewriter.FileWriter do

  def write_posts_file(build_path, root_dir, posts) do
    config = Typewriter.Config.get
    contents = EEx.eval_file(Path.join([root_dir, config.posts_template]), assigns: [posts: posts])
    new_path = Path.join([build_path, Path.basename(root_dir), Path.basename(config.posts_template, ".eex")])
    File.write!(new_path, contents)
  end

  def write_post_files(root_dir, full_path, new_build_full_path) do
    config = Typewriter.Config.get
    IO.puts "F: #{full_path} - N: #{new_build_full_path}"
    Task.async(fn ->
      post = Typewriter.Post.compile(full_path)

      template_content = evaluate_templates(root_dir, config, post)
      json_content = Poison.encode!(post)

      new_html_path = new_post_path(new_build_full_path, ".html")
      new_json_path = new_post_path(new_build_full_path, ".json")

      IO.puts "H: #{new_html_path} - J: #{new_json_path}"

      File.write!(new_html_path, template_content)
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

  defp evaluate_templates(root_dir, config, post) do
    # Evaluate the post template
    post_content = EEx.eval_file(Path.join([root_dir, config.post_template]), assigns: [post: post])
    # Evaluate the layout template, by giving it the evaluated post template
    layout_content = EEx.eval_file(Path.join([root_dir, config.layout_template]), assigns: [content: post_content])

    layout_content
  end

  defp new_post_path(new_build_full_path, ext) do
    Path.join(Path.dirname(new_build_full_path), Path.basename(new_build_full_path, Path.extname(new_build_full_path)) <> ext)
  end
end
