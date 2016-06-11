defmodule Typewriter.CLI do

  def main(args \\ []) do
    args
    |> parse_args
    |> run
    |> response
    |> handle_input
  end

  defp parse_args(args) do
    {opts, project_path, _} =
      args
      |> OptionParser.parse(switches: [port: :number])

    {opts[:port], List.to_string(project_path)}
  end

  def run({port, project_path}) do
    IO.puts "#{port}"
    Typewriter.run(project_path, port)
    {port, project_path}
  end

  defp response({port, project_path}) do
    # Send response
    {port, project_path}
  end

  def handle_input(args)  do
    input = IO.gets "What would you like to do? (s)top, (r)eload: "
    handle_input(args, input |> String.strip)
  end
  def handle_input(args, "s"), do: handle_input(args, "stop")
  def handle_input(args, "r"), do: handle_input(args, "reload")
  def handle_input(_, "stop"), do: :ok
  def handle_input(args, "reload") do
    run(args)
    handle_input(args)
  end
  def handle_input(args, _), do: handle_input(args)

end
