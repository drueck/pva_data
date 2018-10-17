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
      {:meeseeks, "~> 0.10.0"},
      {:httpoison, "~> 1.0"},
      {:absinthe_plug, "~> 1.4.5"},
      {:absinthe_relay, "~> 1.4.4"},
      {:poison, "~> 3.1.0"},
      {:cowboy, "~> 2.5.0"},
      {:plug, "~> 1.6.4"},
      {:distillery, "~> 2.0"}
    ]
  end
end
