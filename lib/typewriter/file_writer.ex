defmodule Typewriter.FileWriter do

  alias Typewriter.Template

  def write_paginated_file(build_path, root_dir, template_file, posts) do
    Task.async(fn ->
      config = Typewriter.Config.get
      posts
      |> create_paginated_posts(config)
      |> Enum.map(fn {paginated_posts, current_index, max_index} ->
        contents = Template.eval(Path.join([root_dir, template_file]), assigns: [posts: paginated_posts, current_index: current_index, max_index: max_index])
        {new_dir_path, new_file_path} = new_paginated_path(build_path, root_dir, template_file, current_index)
        File.mkdir(new_dir_path)
        write_layout(root_dir, new_file_path, contents)
      end)
    end)
  end

  def create_paginated_posts(posts, config) do
    paginated_posts = Typewriter.Paginator.paginate(posts, config.paginate)
    paginated_posts
    |> Stream.with_index(1)
    |> Enum.map(fn {post, index} -> {post, index, Enum.count(paginated_posts)} end)
  end

  def new_paginated_path(build_path, root_dir, template_file, index) do
    # Template without eex, but html
    html_file = Path.basename(template_file, Path.extname(template_file))
    # Template without extension
    no_extension = Path.basename(html_file, Path.extname(html_file))
    # Construct new paginated name
    new_dir_path = Path.join([build_path, Path.basename(root_dir), no_extension, "#{index}"])
    new_file_path = Path.join([new_dir_path, "index" <> Path.extname(html_file)])
    {new_dir_path, new_file_path}
  end

  def write_plural_file(build_path, root_dir, template_file, assigns \\ []) do
    Task.async(fn ->
      config = Typewriter.Config.get
      contents = Template.eval(Path.join([root_dir, template_file]), assigns: assigns)
      if (String.contains?(template_file, "index")) do
        new_path = Path.join([build_path, Path.basename(root_dir), Path.basename(template_file, Path.extname(template_file))])
        write_layout(root_dir, new_path, contents)
      else
        new_dir = Path.join([build_path, Path.basename(root_dir), Template.file_name(template_file)])
        new_path = Path.join([new_dir, "index.html"])
        File.mkdir(new_dir)
        write_layout(root_dir, new_path, contents)
      end
    end)
  end

  def evaluate_with_layout(root_dir, new_build_full_path, contents) do
      {new_dir_path, new_html_path} = new_singular_path(new_build_full_path, ".html")

      File.mkdir(new_dir_path)
      write_layout(root_dir, new_html_path, contents)
  end

  def write_layout(root_dir, new_path, contents) do
    config = Typewriter.Config.get
    layout_content = Template.eval(Path.join([root_dir, config.layout_template]), assigns: [content: contents])
    File.write!(new_path, layout_content)
  end

  def write_author_file(root_dir, full_path, new_build_full_path) do
    config = Typewriter.Config.get
    Task.async(fn ->
      author = Typewriter.Author.compile(full_path)

      author_content = Template.eval(Path.join([root_dir, config.author_template]), assigns: [author: author])

      {new_dir_path, new_html_path} = new_singular_path(new_build_full_path, ".html")

      File.mkdir(new_dir_path)
      write_layout(root_dir, new_html_path, author_content)

      author
    end)
  end

  def write_post_file(root_dir, full_path, new_build_full_path) do
    config = Typewriter.Config.get
    Task.async(fn ->
      post = Typewriter.Post.compile(full_path, root_dir)

      post_content = Template.eval(Path.join([root_dir, config.post_template]), assigns: [post: post, recommended_posts: Typewriter.Post.recommend(post)])

      # Evaluate the layout template, by giving it the evaluated post template
      layout_content = Template.eval(Path.join([root_dir, config.layout_template]), assigns: [content: post_content])

      json_content = Poison.encode!(post)

      {new_dir_path, new_html_path} = new_singular_path(new_build_full_path, ".html")

      File.mkdir(new_dir_path)
      File.write!(new_html_path, layout_content)

      post
    end)
  end

  def copy_dir_and_get_valid_children(full_path, new_build_full_path, ignored_dirs) do
    File.mkdir(new_build_full_path)
    # prepare dir children and their paths
    full_path
    |> File.ls!
    |> Enum.filter(fn f -> !Enum.member?(ignored_dirs, f) end)
    |> Enum.map(fn f -> Path.join([full_path, f]) end)
  end

  def copy_file(full_path, new_build_full_path) do
    Task.async(fn ->
      if (Path.extname(full_path) == ".html") do
        {new_dir, new_file} = new_singular_path(new_build_full_path, ".html")
        File.mkdir(new_dir)
        File.copy!(full_path, new_file)
      else
        File.copy!(full_path, new_build_full_path)
      end
    end)
  end

  defp new_singular_path(new_build_full_path, ext) do
    new_dir_path = Path.join(Path.dirname(new_build_full_path), Path.basename(new_build_full_path, Path.extname(new_build_full_path)))
    new_file_path = Path.join([new_dir_path, "index" <> ext])
    {new_dir_path, new_file_path}
  end
end
