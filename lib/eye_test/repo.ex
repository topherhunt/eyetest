defmodule EyeTest.Repo do
  use Ecto.Repo,
    otp_app: :eye_test,
    adapter: Ecto.Adapters.Postgres
  import Ecto.Query
  alias EyeTest.Repo

  def count(query), do: query |> select([t], count(t.id)) |> Repo.one()

  def any?(query), do: count(query) >= 1

  def first(query), do: query |> limit(1) |> Repo.one()

  # Raises if none found
  def first!(query), do: query |> limit(1) |> Repo.one!()
end
