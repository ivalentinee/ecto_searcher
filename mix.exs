defmodule EctoSearcher.MixProject do
  use Mix.Project

  def project do
    [
      app: :ecto_searcher,
      version: "0.1.1",
      elixir: "~> 1.6",
      elixirc_paths: elixirc_paths(Mix.env()),
      description: "Totally not an attempt to build Ransack-like search",
      package: package(),
      docs: docs(),
      deps: deps()
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
      {:ecto, github: "elixir-ecto/ecto"}, # waiting for ecto 3.2
      {:ex_doc, "~> 0.19", only: :dev},
      {:ecto_sql, github: "elixir-ecto/ecto_sql", only: :test, optional: true},
      {:postgrex, ">= 0.0.0", only: :test, optional: true}
    ]
  end
end
