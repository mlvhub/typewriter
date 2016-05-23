defmodule Typewriter.FileSystem do

  @build_folder "typewriter_build"
  @ignored_folders [@build_folder, "templates"]
  @ignored_extensions ["eex", "yaml"]

  def clean_build_folder(build_path) do
    File.rm_rf!(build_path)
    File.mkdir!(build_path)
  end

  def build(root_dir) do
    build_path = Path.join([root_dir, @build_folder])
    clean_build_folder(build_path)

    handle_file(build_path, root_dir, [])
    |> Enum.map(&Task.await/1)

    write_posts_file(build_path, root_dir)
    write_post_file(build_path, root_dir)
  end

  def write_posts_file(build_path, root_dir) do
    config = Typewriter.Config.get
    contents = EEx.eval_file(Path.join([root_dir, config.posts_template]), assigns: [posts: Typewriter.Post.list])
    new_path = Path.join([build_path, Path.basename(root_dir), Path.basename(config.posts_template, ".eex")])
    File.write!(new_path, contents)
  end
  
  def write_post_file(build_path, root_dir) do
    config = Typewriter.Config.get
    Typewriter.Post.list
    |> Enum.map(fn post ->
      Task.async(fn ->
        contents = EEx.eval_file(Path.join([root_dir, config.post_template]), assigns: [post: post])
        {post, contents}
      end)
    end)
    |> Enum.map(&Task.await/1)
    |> Enum.map(fn {post, contents} ->
      Task.async(fn ->
        new_path = Path.join([build_path, Path.basename(root_dir), config.posts_dir, post.slug <> ".html"])
        File.write!(new_path, contents)
      end)
    end)
    |> Enum.map(&Task.await/1)
  end

  def handle_file(build_full_path, full_path, tasks) do
    new_build_full_path = Path.join([build_full_path, Path.basename(full_path)])
    cond do
      File.dir?(full_path) ->
        # copy the dir and handle the dir's children remotely
        File.mkdir!(new_build_full_path)
        # prepare dir children and their paths
        full_path
        |> File.ls!
        |> Enum.filter(fn f -> !Enum.member?(@ignored_folders, f) end)
        |> Enum.map(fn f -> Path.join([full_path, f]) end)
        |> Enum.flat_map(fn x -> handle_file(new_build_full_path, x, tasks) end)
      Enum.member?(@ignored_extensions, Path.extname(full_path)) ->
        tasks
      Path.extname(full_path) == ".md" ->
        # compile the markdown to html
        task = Task.async(fn ->
          post = Typewriter.Post.compile(full_path)
          Typewriter.Post.add(post)
          # if there is no posts_dir in the config file, we'll use the first markdown as a default
          if (Typewriter.Config.get.posts_dir == nil) do
            Typewriter.Config.update(%{posts_dir: build_full_path})
          end
        end)
        [task | tasks]
      true ->
        # just copy the file
        task = Task.async(fn ->
          File.copy!(full_path, new_build_full_path)
        end)
        [task | tasks]
    end
  end

end
