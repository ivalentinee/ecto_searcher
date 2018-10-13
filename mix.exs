defmodule EctoSearcher.MixProject do
  use Mix.Project

  def project do
    [
      app: :ecto_searcher,
      version: "0.1.0",
      elixir: "~> 1.6",
      elixirc_paths: elixirc_paths(Mix.env()),
      deps: deps()
    ]
  end

  defp elixirc_paths(:test), do: ["lib", "test/support"]
  defp elixirc_paths(_), do: ["lib"]

  defp deps do
    [{:ecto, "~> 2.1"}]
  end
end
