defmodule EyeTest.Data.Location do
  use Ecto.Schema
  import Ecto.Changeset
  require Ecto.Query
  alias Ecto.Query, as: Q
  alias EyeTest.Data
  alias EyeTest.Repo

  schema "locations" do
    belongs_to :user, Data.User
    # Description of this room & your location in it
    field :name, :string
    field :cm_from_screen, :integer
    timestamps()
  end

  #
  # Public
  #

  def get!(id, flt \\ []), do: __MODULE__ |> apply_filters([{:id, id} | flt]) |> Repo.one!()
  def first(filters \\ []), do: __MODULE__ |> apply_filters(filters) |> Repo.first()
  def all(filters \\ []), do: __MODULE__ |> apply_filters(filters) |> Repo.all()
  def count(filters \\ []), do: __MODULE__ |> apply_filters(filters) |> Repo.count()

  def insert(params), do: new_changeset(params) |> Repo.insert()

  def insert!(params), do: insert(params) |> Repo.ensure_success()

  def update(struct, params), do: changeset(struct, params) |> Repo.update()

  def update!(struct, params), do: update(struct, params) |> Repo.ensure_success()

  def delete!(struct), do: Repo.delete!(struct)

  def new_changeset(params \\ %{}), do: changeset(%__MODULE__{}, params)

  def changeset(user, params \\ %{}) do
    user
    |> cast(params, [:user_id, :name, :cm_from_screen])
    |> validate_required([:user_id, :name, :cm_from_screen])
  end

  #
  # Filters
  #

  def apply_filters(starting_query, filters) do
    Enum.reduce(filters, starting_query, fn {k, v}, query -> filter(query, k, v) end)
  end

  def filter(query, :id, id), do: Q.where(query, [l], l.id == ^id)
  def filter(query, :user, user), do: Q.where(query, [l], l.user_id == ^user.id)
  def filter(query, :order, :name), do: Q.order_by(query, [l], asc: l.name)
end
