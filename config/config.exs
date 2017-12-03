# This file is responsible for configuring your application
# and its dependencies with the aid of the Mix.Config module.
#
# This configuration file is loaded before any dependency and
# is restricted to this project.
use Mix.Config

# General application configuration
config :tartupark,
  ecto_repos: [Tartupark.Repo]

# Configures the endpoint
config :tartupark, Tartupark.Endpoint,
  url: [host: "localhost"],
  secret_key_base: "wDGgJJfQL3xIk2Ze7KhPuT8Oo56jIY9N7H3TcN+H3b2KuEjMeDlYIhkc2FIUgPRv",
  render_errors: [view: Tartupark.ErrorView, accepts: ~w(html json)],
  pubsub: [name: Tartupark.PubSub,
           adapter: Phoenix.PubSub.PG2]

# Configures Elixir's Logger
config :logger, :console,
  format: "$time $metadata[$level] $message\n",
  metadata: [:request_id]

# Import environment specific config. This must remain at the bottom
# of this file so it overrides the configuration defined above.
import_config "#{Mix.env}.exs"

config :guardian, Guardian,
  issuer: "Tartupark",
  ttl: {30, :days},
  allowed_drift: 200,
  secret_key: "hL16o3nOa7wP4PGW9HaQKGDBl5Kb/zkKP6L/DmFyix8hyWmWzTGSBAKCBmnwg+RL",
  serializer: Tartupark.GuardianSerializer

config :tartupark, gmaps_api_key: "AIzaSyDV4MrzXfmtCp3nC9gfjQsyPebydgk65c8"