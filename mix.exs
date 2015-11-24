defmodule Obelisk.Mixfile do
  use Mix.Project

  def project do
    [app: :obelisk,
     version: "0.11.0",
     elixir: "~> 1.0",
     package: package,
     docs: [readme: true, main: "README.md"],
     description: """
      obelisk is a static site generator for Elixir. It is inspired by jekyll,
      with the goal of being fast and simple to use and extend.
     """,
     deps: deps]
  end

  def application do
    [applications: [:yamerl, :cowboy, :plug, :chronos],
     mod: {Obelisk, []}]
  end

  defp deps do
    [{:yamerl, github: "yakaz/yamerl"},
     {:earmark, "~> 0.1"},
     {:chronos, "~> 1.0"},
     {:cowboy, "~> 1.0"},
     {:plug, "~> 1.0"},
     {:rss, "~> 0.2"},
     {:mock, "~> 0.1", only: :test},
     {:credo, "~> 0.1", only: [:dev, :test]}
    ]
  end

  defp package do
    %{
      licenses: ["MIT"],
      contributors: ["Benny Hallett", "Clark Kampfe"],
      links: %{"Github" => "https://github.com/ckampfe/obelisk"}
     }
  end
end
