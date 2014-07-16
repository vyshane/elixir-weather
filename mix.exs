defmodule Weather.Mixfile do
  use Mix.Project

  def project do
    [app: :weather,
     version: "0.0.1",
     name: "Elixir Weather",
     source_url: "https://github.com/vyshane/elixir-weather",
     elixir: "~> 0.14.2",
     escript: escript_config,
     deps: deps]
  end

  # Configuration for the OTP application
  #
  # Type `mix help compile.app` for more information
  def application do
    [applications: [:httpotion]]
  end

  # Dependencies can be hex.pm packages:
  #
  #   {:mydep, "~> 0.3.0"}
  #
  # Or git/path repositories:
  #
  #   {:mydep, git: "https://github.com/elixir-lang/mydep.git", tag: "0.1"}
  #
  # Type `mix help deps` for more examples and options
  defp deps do
    [
      {:pipe, github: "batate/elixir-pipes"},
      {:httpotion, github: "myfreeweb/httpotion" },
      {:jsonex, github: "marcelog/jsonex"},
      {:ex_doc, github: "elixir-lang/ex_doc"},
      {:markdown, github: "devinus/markdown"}
    ]
  end

  defp escript_config do
    [main_module: Weather.CLI]
  end
end
