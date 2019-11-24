defmodule Limitex.MixProject do
  use Mix.Project

  @version "0.1.1"

  def project do
    [
      app: :limitex,
      version: @version,
      description: "A pure Elixir distributed rate limiter",
      package: package(),
      source_url: "https://github.com/pggalaviz/limitex",
      homepage_url: "https://github.com/pggalaviz/limitex",
      elixir: "~> 1.6",
      start_permanent: Mix.env() == :prod,
      elixirc_paths: elixirc_paths(Mix.env()),
      deps: deps(),
      docs: docs(),
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
      {:shards, "~> 0.6.1"},
      # Benchmarking dependencies
      {:benchee, "~> 1.0", only: [:dev]},
      # Docs
      {:ex_doc, "~> 0.21.2"}
    ]
  end

  defp package do
    [
      name: :limitex,
      maintainers: ["Pedro G. Galaviz (hello@pggalaviz.com)"],
      licenses: ["MIT"],
      links: %{"GitHub" => "https://github.com/pggalaviz/limitex"},
      files: ~w(lib .formatter.exs mix.exs README* LICENSE*)
    ]
  end

  defp docs do
    [
      source_ref: "v#{@version}",
      canonical: "http://hexdocs.pm/limitex",
      source_url: "https://github.com/pggalaviz/limitex",
      extras: [
        "README.md"
      ]
    ]
  end

  # Specifies which paths to compile per environment.
  defp elixirc_paths(:test), do: ["lib", "test/support"]
  defp elixirc_paths(_), do: ["lib"]
end
