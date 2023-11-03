defmodule PVAData.MixProject do
  use Mix.Project

  def project do
    [
      app: :pva_data,
      version: "0.1.0",
      elixir: "~> 1.10",
      start_permanent: Mix.env() == :prod,
      deps: deps(),
      releases: [
        pva_data: [
          include_executables_for: [:unix]
        ]
      ],
      default_release: :pva_data
    ]
  end

  # Run "mix help compile.app" to learn about applications.
  def application do
    [
      extra_applications: [:logger],
      mod: {PVAData.Application, []}
    ]
  end

  # Run "mix help deps" to learn about dependencies.
  defp deps do
    [
      {:absinthe_plug, "~> 1.5.8"},
      {:cors_plug, "~> 2.0.2"},
      {:cowboy, "~> 2.7.0"},
      {:httpoison, "~> 2.1.0"},
      {:jason, "~> 1.1"},
      {:joken, "~> 2.0"},
      {:meeseeks, "~> 0.17.0"},
      {:plug, "~> 1.10.0"},
      {:plug_cowboy, "~> 2.1.2"},
      {:poison, "~> 5.0.0"},
      {:redix, "~> 1.3.0"},
      {:rollbax, "~> 0.11.0"},
      {:slugger, "~> 0.3.0"},
      {:uuid, "~> 1.1.8"}
    ]
  end
end
