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

  defp deps do
    [
      {:ecto, "~> 2.1"},
      {:ex_doc, "~> 0.19", only: :dev}
    ]
  end
end
