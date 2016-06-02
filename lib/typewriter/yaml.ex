defmodule Typewriter.Yaml do

  def compile(file) do
    file |> File.read! |> parse
  end

  def parse(yaml) do
    [parsed] = :yamerl_constr.string(yaml)
    parsed
  end

  def get_prop(props, key, default \\ nil) do
    case :proplists.get_value(String.to_char_list(key), props) do
      :undefined -> default
      x -> to_string(x)
    end
  end

  def get_list(props, key) do
    props
    |> get_prop(key, "")
    |> String.split([" ", ","])
    |> Enum.filter(fn x -> x != "" end)
  end

end
