defmodule Typewriter do
  use Application

  # See http://elixir-lang.org/docs/stable/elixir/Application.html
  # for more information on OTP Applications
  def start(_type, _args) do
    import Supervisor.Spec, warn: false

    children = [
      worker(Typewriter.Config, []),
      worker(Typewriter.Post, []),
    ]

    opts = [strategy: :one_for_one, name: Typewriter.Supervisor]
    Supervisor.start_link(children, opts)
  end

  def run(root_dir, port \\ 8000) do
    dir_path = generate(root_dir)
    start_server(dir_path, port)
  end

  def generate(root_dir) do
    Supervisor.start_child(Typewriter.Supervisor, [])
    Typewriter.Config.init(root_dir)
    Typewriter.FileSystem.generate(root_dir)
  end

  def start_server(root_dir, port \\ 8000) do
    Typewriter.Server.start(root_dir)
  end
end
