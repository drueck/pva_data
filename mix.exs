defmodule PVAData.MixProject do
  use Mix.Project

  def project do
    [
      app: :pva_data,
      version: "0.1.0",
      elixir: "~> 1.7",
      start_permanent: Mix.env() == :prod,
      deps: deps()
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
      {:absinthe_plug, "~> 1.4.5"},
      {:absinthe_relay, "~> 1.4.4"},
      {:cors_plug, "~> 2.0.0"},
      {:cowboy, "~> 2.6.3"},
      {:plug_cowboy, "~> 2.0"},
      {:distillery, "~> 2.0"},
      {:httpoison, "~> 1.0"},
      {:meeseeks, "~> 0.11.0"},
      {:plug, "~> 1.8.0"},
      {:poison, "~> 4.0.1"},
      {:uuid, "~> 1.1.8"}
    ]
  end
end
