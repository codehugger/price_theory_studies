use Mix.Config

config :mastery_persistence, MasteryPersistence.Repo,
  adapter: Ecto.Adapters.Postgres,
  database: "mastery_dev",
  hostname: "localhost"
