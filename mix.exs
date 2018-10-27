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
      {:cors_plug, "~> 1.5"},
      {:cowboy, "~> 2.5.0"},
      {:distillery, "~> 2.0"},
      {:httpoison, "~> 1.0"},
      {:meeseeks, "~> 0.10.0"},
      {:plug, "~> 1.6.4"},
      {:poison, "~> 3.1.0"},
      {:uuid, "~> 1.1.8"}
    ]
  end
end
