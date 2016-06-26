defmodule Typewriter.Paginator do

  def paginate([], _), do: []
  def paginate(list, size) do
    [ Enum.take(list, size) | paginate(Enum.drop(list, size), size) ]
  end

end
