defmodule Typewriter.CLI do

  def main(args \\ []) do
    args
    |> parse_args
    |> response
    |> output
  end

  defp parse_args(args) do
    {opts, project_path, _} =
      args
      |> OptionParser.parse(switches: [])

    {opts, List.to_string(project_path)}
  end

  defp response({_opts, project_path}) do
    Typewriter.generate(project_path)
  end

  def output(_result) do
    ""
  end

end
