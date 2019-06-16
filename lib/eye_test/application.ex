defmodule EyeTest.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  def start(_type, _args) do
    # List all child processes to be supervised
    children = [
      # Start the Ecto repository
      EyeTest.Repo,
      # Start the endpoint when the application starts
      EyeTestWeb.Endpoint
      # Starts a worker by calling: EyeTest.Worker.start_link(arg)
      # {EyeTest.Worker, arg},
    ]

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: EyeTest.Supervisor]

    # Subscribe to Ecto queries for logging
    # See https://hexdocs.pm/ecto/Ecto.Repo.html#module-telemetry-events
    # and https://github.com/beam-telemetry/telemetry
    handler = &EyeTest.Telemetry.handle_event/4
    :ok = :telemetry.attach("eye_test_ecto", [:eye_test, :repo, :query], handler, %{})

    Supervisor.start_link(children, opts)
  end

  # Tell Phoenix to update the endpoint configuration
  # whenever the application is updated.
  def config_change(changed, _new, removed) do
    EyeTestWeb.Endpoint.config_change(changed, removed)
    :ok
  end
end
