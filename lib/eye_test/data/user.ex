defmodule EyeTest.Data.User do
  use Ecto.Schema
  import Ecto.Changeset
  require Ecto.Query
  alias Ecto.Query, as: Q
  alias EyeTest.Data
  alias EyeTest.Repo

  schema "users" do
    field :name, :string
    field :email, :string
    field :auth0_uid, :string
    field :last_signed_in_at, :utc_datetime
    timestamps()

    has_many :locations, Data.Location
    has_many :assessments, Data.Assessment
  end

  #
  # Public
  #

  def get(id, filt \\ []), do: get_by(Keyword.merge([id: id], filt))

  def get!(id, filt \\ []), do: get_by!(Keyword.merge([id: id], filt))

  def get_by(filt), do: __MODULE__ |> filter(filt) |> Repo.first()

  def get_by!(filt), do: __MODULE__ |> filter(filt) |> Repo.first!()

  def all(filt \\ []), do: __MODULE__ |> filter(filt) |> Repo.all()

  def count(filt \\ []), do: __MODULE__ |> filter(filt) |> Repo.count()

  def insert(params), do: new_changeset(params) |> Repo.insert()

  def insert!(params), do: insert(params) |> Repo.ensure_success()

  def update(struct, params), do: changeset(struct, params) |> Repo.update()

  def update!(struct, params), do: update(struct, params) |> Repo.ensure_success()

  def delete!(struct), do: Repo.delete!(struct)

  # TODO: Require certain filters so I can't nuke the whole db
  def delete_all!(filt), do: __MODULE__ |> filter(filt) |> Repo.delete_all()

  def new_changeset(params \\ %{}), do: changeset(%__MODULE__{}, params)

  def changeset(user, attrs) do
    user
    |> cast(attrs, [:name, :email, :auth0_uid, :last_signed_in_at])
    |> validate_required([:name, :email])
    |> unique_constraint(:email)
    |> unique_constraint(:auth0_uid)
  end

  #
  # Filters
  #

  def filter(starting_query, filters) do
    Enum.reduce(filters, starting_query, fn {k, v}, query -> filter(query, k, v) end)
  end

  def filter(query, :id, id), do: Q.where(query, [u], u.id == ^id)
  def filter(query, :email, email), do: Q.where(query, [u], u.email == ^email)
  def filter(query, :auth0_uid, uid), do: Q.where(query, [u], u.auth0_uid == ^uid)
end
