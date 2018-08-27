defmodule EctoSearcher.MixProject do
  use Mix.Project

  def project do
    [
      app: :ecto_searcher,
      version: "0.1.0",
      elixir: "~> 1.6",
      elixirc_paths: elixirc_paths(Mix.env()),
      start_permanent: Mix.env() == :prod,
      deps: deps()
    ]
  end

  defp elixirc_paths(:test), do: ["lib", "test/support"]
  defp elixirc_paths(_), do: ["lib"]

  # Run "mix help compile.app" to learn about applications.
  def application do
    [extra_applications: extra_applications(Mix.env())]
  end

  defp extra_applications(:test), do: [:logger]
  defp extra_applications(_), do: [:logger]

  # Run "mix help deps" to learn about dependencies.
  defp deps do
    [{:ecto, "~> 2.1"}]
  end
end
