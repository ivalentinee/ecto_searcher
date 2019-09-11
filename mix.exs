defmodule EctoSearcher.MixProject do
  use Mix.Project

  def project do
    [
      app: :ecto_searcher,
      version: "0.2.0",
      elixir: "~> 1.6",
      elixirc_paths: elixirc_paths(Mix.env()),
      description: "Totally not an attempt to build Ransack-like search",
      package: package(),
      docs: docs(),
      deps: deps(),
      test_coverage: [tool: ExCoveralls],
      preferred_cli_env: [
        coveralls: :test,
        "coveralls.detail": :test,
        "coveralls.post": :test,
        "coveralls.html": :test
      ]
    ]
  end

  def package do
    [
      licenses: ["MIT"],
      links: %{"GitHub" => "https://github.com/ivalentinee/ecto_searcher"}
    ]
  end

  defp docs do
    [
      main: "EctoSearcher",
      source_url: "https://github.com/ivalentinee/ecto_searcher"
    ]
  end

  defp elixirc_paths(:test), do: ["lib", "test/support"]
  defp elixirc_paths(_), do: ["lib"]

  defp extra_applications(:test), do: [:logger, :postgrex]
  defp extra_applications(_), do: []

  def application do
    [extra_applications: extra_applications(Mix.env())]
  end

  defp deps do
    [
      {:ecto, "~> 3.2"},
      {:ex_doc, "~> 0.19", only: :dev, runtime: false},
      {:ecto_sql, "~> 3.2", only: :test, optional: true},
      {:postgrex, ">= 0.0.0", only: :test, optional: true},
      {:excoveralls, "~> 0.10", only: :test, optional: true}
    ]
  end
end
