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
      |> OptionParser.parse(switches: [port: :number])

    {opts, List.to_string(project_path)}
  end

  defp response({opts, project_path}) do
    IO.puts "#{opts[:port]}"
    Typewriter.run(project_path, opts[:port])
  end

  def output(_result) do
    :timer.sleep(:infinity)
  end

end
