use Mix.Config

# We don't run a server during test. If one is required,
# you can enable the server option below.
config :eye_test, EyeTestWeb.Endpoint,
  http: [port: 4002],
  server: false

# Print only warnings and errors during test
config :logger, level: :warn

# Configure your database
config :eye_test, EyeTest.Repo,
  username: "postgres",
  password: "postgres",
  database: "eye_test_test",
  hostname: "localhost",
  pool: Ecto.Adapters.SQL.Sandbox
