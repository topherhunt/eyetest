defmodule EyeTest.Repo do
  use Ecto.Repo,
    otp_app: :eye_test,
    adapter: Ecto.Adapters.Postgres
end
