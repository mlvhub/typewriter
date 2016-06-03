defmodule Typewriter.CLI do

  def main(args \\ []) do
    args
    |> parse_args
    |> response
    |> IO.inspect
  end

  defp parse_args(args) do
    {opts, project_path, _} =
      args
      |> OptionParser.parse(switches: [])

    {opts, List.to_string(project_path)}
  end

  defp response({opts, project_path}) do
    Typewriter.build(project_path)
  end

end
