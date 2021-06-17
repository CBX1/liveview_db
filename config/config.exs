use Mix.Config

config :pokemon_db,
  ecto_repos: [PokemonDb.Repo]

# Configures the endpoint
config :pokemon_db, PokemonDbWeb.Endpoint,
  url: [host: "localhost"],
  secret_key_base: "WOmBjeenALCoQa9o8Vi01UD9MB4qtIWrymXD2a9jddnc00yg20uiXd6UA35OxRjz",
  render_errors: [view: PokemonDbWeb.ErrorView, accepts: ~w(html json), layout: false],
  pubsub_server: PokemonDb.PubSub,
  live_view: [signing_salt: "pbc+TCmw"]

# Configures Elixir's Logger
config :logger, :console,
  format: "$time $metadata[$level] $message\n",
  metadata: [:request_id]

# Use Jason for JSON parsing in Phoenix
config :phoenix, :json_library, Jason

# Import environment specific config. This must remain at the bottom
# of this file so it overrides the configuration defined above.
import_config "#{Mix.env()}.exs"
