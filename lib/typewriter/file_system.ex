defmodule Typewriter.FileSystem do
  require EEx

  alias Typewriter.Post
  alias Typewriter.Config

  @build_dir "typewriter_build"
  @ignored_dirs [@build_dir, "templates"]
  @ignored_extensions [".eex", ".yaml"]

  def clean(root_dir) do
    build_path = Path.join([root_dir, @build_dir])
    clean_build_dir(build_path)
    build_path
  end

  def build(root_dir) do
    # Ensure a clean start
    Post.clear
    build_path = clean(root_dir)

    build_path
    |> handle_file(root_dir, [])
    |> Enum.forEach(&Task.await/1)

    write_posts_file(build_path, root_dir)
    write_post_file(build_path, root_dir)
  end

  def write_posts_file(build_path, root_dir) do
    config = Config.get
    contents = EEx.eval_file(Path.join([root_dir, config.posts_template]), assigns: [posts: Typewriter.Post.list])
    new_path = Path.join([build_path, Path.basename(root_dir), Path.basename(config.posts_template, ".eex")])
    File.write!(new_path, contents)
  end
  
  def write_post_file(build_path, root_dir) do
    config = Typewriter.Config.get
    Typewriter.Post.list
    |> Enum.map(fn post ->
      Task.async(fn ->
        post_content = EEx.eval_file(Path.join([root_dir, config.post_template]), assigns: [post: post])
        layout_content = EEx.eval_file(Path.join([root_dir, config.layout_template]), assigns: [content: post_content])
        {post, layout_content}
      end)
    end)
    |> Enum.map(&Task.await/1)
    |> Enum.map(fn {post, contents} ->
      Task.async(fn ->
        # TODO: Refactor the file handling
        new_path = Path.join([build_path, Path.basename(root_dir), config.posts_dir, post.slug <> ".html"])
        File.write!(new_path, contents)
        new_path = Path.join([build_path, Path.basename(root_dir), config.posts_dir, post.slug <> ".json"])
        json = Poison.encode!(post)
        File.write!(new_path, json)
      end)
    end)
    |> Enum.map(&Task.await/1)
  end

  def handle_file(build_full_path, full_path, tasks) do
    new_build_full_path = Path.join([build_full_path, Path.basename(full_path)])
    config = Typewriter.Config.get
    cond do
      File.dir?(full_path) ->
        # copy the dir and handle the dir's children remotely
        File.mkdir!(new_build_full_path)
        # prepare dir children and their paths
        full_path
        |> File.ls!
        |> Enum.filter(fn f -> !Enum.member?(Enum.concat(@ignored_dirs, config.ignored_dirs), f) end)
        |> Enum.map(fn f -> Path.join([full_path, f]) end)
        |> Enum.flat_map(fn x -> handle_file(new_build_full_path, x, tasks) end)
      Path.extname(full_path) == ".md" ->
        # compile the markdown to html
        task = Task.async(fn ->
          post = Typewriter.Post.compile(full_path)
        end)
        [task | tasks]
      Enum.member?(@ignored_extensions, Path.extname(full_path)) ->
        tasks
      Enum.member?(config.ignored_files, Path.basename(full_path)) ->
        tasks
      true ->
        # just copy the file
        task = Task.async(fn ->
          File.copy!(full_path, new_build_full_path)
        end)
        [task | tasks]
    end
  end

  defp clean_build_dir(build_path) do
    File.rm_rf!(build_path)
    File.mkdir!(build_path)
  end

end
