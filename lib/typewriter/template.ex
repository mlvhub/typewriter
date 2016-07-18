defmodule Typewriter.Template do

  def eval(file, assigns \\ [], constants \\ Typewriter.Constants.get) do
    new_assigns =
    if (Enum.empty?(assigns)) do
      []
    else
      {_, head} = assigns |> hd
      Enum.concat([constants: constants], head)
    end
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
