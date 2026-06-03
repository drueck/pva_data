defmodule PVAData.MixProject do
  use Mix.Project

  def project do
    [
      app: :pva_data,
      version: "0.1.0",
      elixir: "~> 1.19.5",
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
      {:absinthe_plug, "~> 1.5"},
      {:cors_plug, "~> 3.0"},
      {:cowboy, "~> 2.12"},
      {:req, "~> 0.5"},
      {:jason, "~> 1.4"},
      {:joken, "~> 2.6"},
      {:meeseeks, "~> 0.17"},
      {:plug, "~> 1.16"},
      {:plug_cowboy, "~> 2.8"},
      {:redix, "~> 1.5"},
      {:rollbax, "~> 0.11"},
      {:slugger, "~> 0.3"},
      {:elixir_uuid, "~> 1.2"}
    ]
  end
end
