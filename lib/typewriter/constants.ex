defmodule Typewriter.Constants do

  @file_path "constants.json"

  # Agent API

  def start_link do
    Agent.start_link(fn -> %{} end, name: __MODULE__)
  end

  def init(root_dir) do
    constants_path = Path.join([root_dir, @file_path])

    case File.read(constants_path) do
      {:ok, json} ->
        constants = Poison.decode!(json)
        Agent.update(__MODULE__, fn _ -> constants end)
      {:error, reason} ->
        IO.puts "Constants.init: ERROR: #{reason}"
    end
  end

  def get do
    Agent.get(__MODULE__, &(&1))
  end

  def clear do
    Agent.update(__MODULE__, fn _ -> %{} end)
  end

end
