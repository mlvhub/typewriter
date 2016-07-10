defmodule Typewriter.Template do

  def eval(file, assigns, constants \\ Typewriter.Constants.get) do
    {_, head} = assigns |> hd
    new_assigns = Enum.concat([constants: constants], head)
    EEx.eval_file(file, assigns: new_assigns)
  end

end
