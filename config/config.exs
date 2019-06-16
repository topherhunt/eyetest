# This file is responsible for configuring your application
# and its dependencies with the aid of the Mix.Config module.
#
# This configuration file is loaded before any dependency and
# is restricted to this project.

# General application configuration
use Mix.Config

defmodule H do
  def env!(key), do: System.get_env(key) || raise("Env var '#{key}' is missing!")
end

# Automatically load sensitive environment variables for dev and test
if File.exists?("config/secrets.exs"), do: import_config("secrets.exs")

config :eye_test,
  ecto_repos: [EyeTest.Repo]

# Configure your database
config :eye_test, EyeTest.Repo,
  url: H.env!("DATABASE_URL"),
  # Heroku PG hobby-dev allows max 20 db connections
  pool_size: 10,
  log: false

# Configures the endpoint
config :eye_test, EyeTestWeb.Endpoint,
  url: [host: "localhost"],
  secret_key_base: H.env!("SECRET_KEY_BASE"),
  render_errors: [view: EyeTestWeb.ErrorView, accepts: ~w(html json)],
  pubsub: [name: EyeTest.PubSub, adapter: Phoenix.PubSub.PG2],
  live_view: [signing_salt: H.env!("SIGNING_SALT")]

config :phoenix, :template_engines, leex: Phoenix.LiveView.Engine

config :phoenix, :json_library, Jason

# Configures Elixir's Logger
config :logger, :console,
  format: "$time $metadata[$level] $message\n",
  metadata: [:request_id]

# Use Jason for JSON parsing in Phoenix
config :phoenix, :json_library, Jason

config :oauth2, serializers: %{"application/json" => Jason}

config :ueberauth, Ueberauth,
  providers: [
    auth0: {
      Ueberauth.Strategy.Auth0,
      [request_path: "/auth/login", callback_path: "/auth/auth0_callback"]
    }
  ]

config :ueberauth, Ueberauth.Strategy.Auth0.OAuth,
  domain: H.env!("AUTH0_DOMAIN"),
  client_id: H.env!("AUTH0_CLIENT_ID"),
  client_secret: H.env!("AUTH0_CLIENT_SECRET")

# Import environment specific config. This must remain at the bottom
# of this file so it overrides the configuration defined above.
import_config "#{Mix.env()}.exs"
