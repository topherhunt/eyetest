use Mix.Config

config :eye_test, EyeTestWeb.Endpoint,
  http: [port: 4002],
  server: true

# Log ALL messages (default is :warn) but route them to a logfile.
config :logger,
  backends: [{LoggerFileBackend, :test_log}]

config :logger, :test_log,
  path: "log/test.log",
  format: "$date $time $metadata[$level] $message\n",
  # :debug for ALL queries etc; :brief for only the basics
  level: :debug

# Configure your database
config :eye_test, EyeTest.Repo,
  pool: Ecto.Adapters.SQL.Sandbox,
  # long timeout to allow debugging in tests
  ownership_timeout: 20 * 60 * 1000

config :eye_test, EyeTest.Mailer, adapter: Bamboo.TestAdapter

config :hound, driver: "chrome_driver", browser: "chrome_headless"

config :rollbax, enabled: false
