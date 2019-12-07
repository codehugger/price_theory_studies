# This file is responsible for configuring your umbrella
# and **all applications** and their dependencies with the
# help of Mix.Config.
#
# Note that all applications in your umbrella share the
# same configuration and dependencies, which is why they
# all use the same configuration file. If you want different
# configurations or dependencies per app, it is best to
# move said applications out of the umbrella.
use Mix.Config

# Configure Mix tasks and generators
config :threadneedle,
  ecto_repos: [Threadneedle.Repo]

config :threadneedle_web,
  ecto_repos: [Threadneedle.Repo],
  generators: [context_app: :threadneedle]

# Configures the endpoint
config :threadneedle_web, ThreadneedleWeb.Endpoint,
  url: [host: "localhost"],
  secret_key_base: "4uM4gqLD8Z8g5AeOxiF3lFGUeV6RBDLug/4e48eK5bAL/V152KmlqCW0oZML3WT3",
  render_errors: [view: ThreadneedleWeb.ErrorView, accepts: ~w(html json)],
  pubsub: [name: ThreadneedleWeb.PubSub, adapter: Phoenix.PubSub.PG2]

# Configures Elixir's Logger
config :logger, :console,
  format: "$time $metadata[$level] $message\n",
  metadata: [:request_id]

# Use Jason for JSON parsing in Phoenix
config :phoenix, :json_library, Jason

# Import environment specific config. This must remain at the bottom
# of this file so it overrides the configuration defined above.
import_config "#{Mix.env()}.exs"
