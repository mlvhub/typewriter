defmodule Typewriter.Mixfile do
  use Mix.Project

  def project do
    [app: :typewriter,
     version: "0.0.1",
     elixir: "~> 1.2",
     build_embedded: Mix.env == :prod,
     start_permanent: Mix.env == :prod,
     escript: [main_module: Typewriter.CLI],
     deps: deps]
  end

  # Configuration for the OTP application
  #
  # Type "mix help compile.app" for more information
  def application do
    [applications: [:logger, :yamerl],
     mod: {Typewriter, []}]
  end

  # Dependencies can be Hex packages:
  #
  #   {:mydep, "~> 0.3.0"}
  #
  # Or git/path repositories:
  #
  #   {:mydep, git: "https://github.com/elixir-lang/mydep.git", tag: "0.1.0"}
  #
  # Type "mix help deps" for more examples and options
  defp deps do
    [
      {:earmark, "~> 0.2.0"},
      {:yamerl, github: "yakaz/yamerl"},
      {:poison, "~> 2.0"},
      {:html_sanitize_ex, "~> 1.0.0"},
      {:credo, "~> 0.3", only: [:dev, :test]},
    ]
  end
end
