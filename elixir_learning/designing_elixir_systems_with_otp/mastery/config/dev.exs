use Mix.Config

config :mastery_persistence, MasteryPersistence.Repo,
  database: "mastery_dev",
  hostname: "localhost"

config :mastery, :persistent_fn, &MasteryPersistence.record_response/2
