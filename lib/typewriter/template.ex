defmodule Typewriter.Template do

  def eval(file, assigns, constants \\ Typewriter.Constants.get) do
    {_, head} = assigns |> hd
    new_assigns = Enum.concat([constants: constants], head)
    EEx.eval_file(file, assigns: new_assigns)
  end

  def file_name(path) do
    if (String.contains?(path, ".")) do
      file_name(Path.basename(path, Path.extname(path)))
    else
      path
    end
  end

end
