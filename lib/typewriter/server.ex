defmodule Typewriter.Server do

  def start(root_dir, port \\ 8000) do
    IO.puts "Starting server in #{root_dir}"
    
    routes = [
      {"/", :cowboy_static, {:file, Path.join([root_dir, "index.html"])}},
      {"/[...]", :cowboy_static, {:dir, root_dir}},
    ]

    dispatch = :cowboy_router.compile([{:_, routes}])

    opts = [port: port]
    env = [dispatch: dispatch]

    :cowboy.start_http(:http, 100, opts, [env: env])
  end

end
