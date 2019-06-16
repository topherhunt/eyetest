defmodule EyeTest.Data.Assessment do
  use Ecto.Schema
  import Ecto.Changeset
  require Ecto.Query
  alias Ecto.Query, as: Q
  alias EyeTest.Data
  alias EyeTest.Repo

  schema "assessments" do
    belongs_to :user, Data.User
    belongs_to :location, Data.Location
    # "left_eye", "right_eye", "both_eyes"
    field :setting, :string
    # "letter", "e_direction"
    field :type, :string
    # 1 = the screen is the brightest light source in the room.
    # 5 = other light sources are so bright that it's hard to focus on the screen.
    field :current_light_level, :integer
    # how I'm feeling, what time I woke up, how many hrs of sleep I got, etc.
    field :personal_notes
    # not user-visible. Place for admin to store experimental flags.
    field :other_notes
    # json array of question & result objects shaped like:
    # {size: 26.3 (decimal pct), displayed: "M", guessed: "N", correct: false}
    field :items, {:array, :map}
    # all summary scores (label => score value).  I'm not yet sure what score will be most
    # useful, so I'll just compute and store all the ones I can think of.
    # TODO: Maybe just put these as normal columns on the table?
    field :scores, :map
    timestamps()
    # the moment the 1st question was displayed
    field :started_at, :utc_datetime
    # the moment the final question was answered
    field :completed_at, :utc_datetime
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
    |> cast(attrs, [:user_id, :location_id, :setting, :type, :current_light_level, :personal_notes, :other_notes, :items, :scores, :started_at, :completed_at])
    |> validate_required([:user_id, :location_id, :setting, :type, :current_light_level, :items, :scores, :started_at, :completed_at])
  end

  #
  # Filters
  #

  def filter(starting_query, filters) do
    Enum.reduce(filters, starting_query, fn {k, v}, query -> filter(query, k, v) end)
  end

  def filter(query, :id, id), do: Q.where(query, [l], l.id == ^id)
  def filter(query, :user_id, user_id), do: Q.where(query, [l], l.user_id == ^user_id)
  def filter(query, :location_id, l_id), do: Q.where(query, [l], l.location_id == ^l_id)
  def filter(query, :setting, setting), do: Q.where(query, [l], l.setting == ^setting)
  def filter(query, :type, type), do: Q.where(query, [l], l.type == ^type)
end
