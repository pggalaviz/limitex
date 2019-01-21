defmodule Limitex.MixProject do
  use Mix.Project

  @version 0.1.0

  def project do
    [
      app: :limitex,
      description: "A pure Elixir rate limiter",
      package: [
        name: :limitex,
        maintainers: ["Pedro G. Galaviz (hello@pggalaviz.com)"],
        licenses: ["MIT"],
        links: %{"GitHub" => "https://github.com/pggalaviz/limitex"}
      ],
      source_url: "https://github.com/pggalaviz/limitex",
      homepage_url: "https://github.com/pggalaviz/limitex",
      version: @version,
      elixir: "~> 1.8",
      start_permanent: Mix.env() == :prod,
      deps: deps(),
      preferred_cli_env: [
        bench: :bench
      ],
      aliases: [
        bench: "run benchmarks/main.exs"
      ]
    ]
  end

  # Run "mix help compile.app" to learn about applications.
  def application do
    [
      extra_applications: [:logger],
      mod: {Limitex.Application, []}
    ]
  end

  # Run "mix help deps" to learn about dependencies.
  defp deps do
    [
      # Production dependencies
      {:shards, git: "https://github.com/cabol/shards.git"},
      # Benchmarking dependencies
      {:benchee, "~> 0.13.2", optional: true, only: [:bench]}
    ]
  end
end
