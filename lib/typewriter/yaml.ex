defmodule Typewriter.Yaml do

  def compile(file) do
    file |> File.read! |> parse
  end

  def parse(yaml) do
    [parsed] = :yamerl_constr.string(yaml)
    parsed
  end

  def get_prop(props, key) do
    case :proplists.get_value(String.to_char_list(key), props) do
      :undefined -> nil
      x -> to_string(x)
    end
  end

  def get_tags(props) do
    props
    |> get_prop("tags")
    |> String.split([" ", ","])
    |> Enum.filter(fn x -> x != "" end)
  end

end
