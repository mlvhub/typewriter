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

  def build(root_dir) do
    Supervisor.start_child(Typewriter.Supervisor, [])
    Typewriter.Config.init(root_dir)
    Typewriter.FileSystem.build(root_dir)
  end
end
