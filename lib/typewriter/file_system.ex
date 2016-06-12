defmodule Typewriter.FileSystem do

  alias Typewriter.Post
  alias Typewriter.Config
  alias Typewriter.FileWriter

  @build_dir "typewriter_build"
  @ignored_dirs [@build_dir, "templates"]
  @ignored_extensions [".eex", ".yaml"]

  def generate(root_dir) do
    root_dir
    |> clean
    |> build(root_dir)
  end

  def clean(root_dir) do
    # Ensure a clean start
    build_path = Path.join([root_dir, @build_dir])
    clean_build_dir(build_path)
    Post.clear

    build_path
  end

  def build(build_path, root_dir) do

    root_dir
    |> handle_file(build_path, root_dir, [])
    |> Enum.each(&Task.await/1)

    posts = Post.ordered_list
    FileWriter.write_posts_file(build_path, root_dir, posts)

    _final_path = Path.join([build_path, Path.basename(root_dir)])
  end
  
  def handle_file(root_dir, build_full_path, full_path, tasks) do
    new_build_full_path = Path.join([build_full_path, Path.basename(full_path)])
    config = Config.get
    cond do
      File.dir?(full_path) ->
        # ignored folders
        ignored_dirs = Enum.concat(@ignored_dirs, config.ignored_dirs)
        # copy the dir and handle the dir's children remotely
        full_path
        |> FileWriter.copy_dir_and_get_valid_children(new_build_full_path, ignored_dirs)
        |> Enum.flat_map(fn x -> handle_file(root_dir, new_build_full_path, x, tasks) end)
      Path.extname(full_path) == ".md" ->
        # compile the markdown to html
        task = FileWriter.write_post_files(root_dir, full_path, new_build_full_path)
        [task | tasks]
      Enum.member?(@ignored_extensions, Path.extname(full_path)) ->
        tasks
      Enum.member?(config.ignored_files, Path.basename(full_path)) ->
        tasks
      true ->
        task = FileWriter.copy_file(full_path, new_build_full_path)
        # just copy the file
        [task | tasks]
    end
  end

  defp clean_build_dir(build_path) do
    File.rm_rf!(build_path)
    File.mkdir!(build_path)
  end

end
