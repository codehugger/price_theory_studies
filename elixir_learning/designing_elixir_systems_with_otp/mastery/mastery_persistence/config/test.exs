use Mix.Config

config :mastery_persistence, MasteryPersistence.Repo,
  adapter: Ecto.Adapters.Postgres,
  database: "mastery_test",
  hostname: "localhost",
  pool: Ecto.Adapters.SQL.Sandbox
