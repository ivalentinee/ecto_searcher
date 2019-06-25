use Mix.Config

if Mix.env() == :test do
  config :ecto_searcher, ecto_repos: [EctoSearcher.TestRepo]

  config :ecto_searcher, EctoSearcher.TestRepo,
    username: "postgres",
    password: "postgres",
    database: "db",
    hostname: System.get_env("DB_HOST") || "localhost",
    pool: Ecto.Adapters.SQL.Sandbox,
    pool_size: 10
end
