use Mix.Config

if Mix.env() == :test do
  config :ecto_searcher, ecto_repos: [EctoSearcher.TestRepo]

  config :ecto_searcher, EctoSearcher.TestRepo,
    username: "postgres",
    password: "postgres",
    database: "db",
    hostname: "db",
    pool: Ecto.Adapters.SQL.Sandbox,
    pool_size: 10

  config :logger, level: :warn
end
