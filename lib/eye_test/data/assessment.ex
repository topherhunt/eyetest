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

    # Random string we use in the pubsub channel names to pair the screen + phone.
    field :uuid, :string, virtual: true

    # options: "left", "right", "both"
    field :which_eye, :string

    # 1 = the screen is the brightest light source in the room.
    # 5 = other light sources are so bright that it's hard to focus on the screen.
    field :current_light_level, :integer

    # how I'm feeling, what time I woke up, how many hrs of sleep I got, etc.
    field :personal_notes

    # not user-visible. Place for admin to store experimental flags.
    field :other_notes

    # array of Question objects, each having the following keys: %{
    #   size: decimal (100.0% - 0.01%)
    #   actual: string (eg. "M")
    #   guess: string (eg. "N", or "" if timed out)
    #   correct: bool
    #   step: virtual string (["countdown", "reveal", "result"])
    #   uuid: virtual string (used to differentiate questions during timeout)
    # }
    field :questions, {:array, :map}

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

  def one(filters \\ []),    do: __MODULE__ |> apply_filters(filters) |> Repo.one()
  def one!(filters \\ []),   do: __MODULE__ |> apply_filters(filters) |> Repo.one!()
  def first(filters \\ []),  do: __MODULE__ |> apply_filters(filters) |> Repo.first()
  def first!(filters \\ []), do: __MODULE__ |> apply_filters(filters) |> Repo.first!()
  def all(filters \\ []),    do: __MODULE__ |> apply_filters(filters) |> Repo.all()
  def count(filters \\ []),  do: __MODULE__ |> apply_filters(filters) |> Repo.count()

  def insert(params), do: complete_changeset(%__MODULE__{}, params) |> Repo.insert()

  def insert!(params), do: insert(params) |> Repo.ensure_success()

  def update(struct, params), do: complete_changeset(struct, params) |> Repo.update()

  def update!(struct, params), do: update(struct, params) |> Repo.ensure_success()

  def delete!(struct), do: Repo.delete!(struct)

  def settings_changeset(struct, attrs \\ %{}) do
    struct
    |> cast(attrs, [:location_id, :which_eye, :current_light_level, :personal_notes, :other_notes])
    |> validate_required([:location_id, :which_eye, :current_light_level])
    |> validate_inclusion(:which_eye, ["left", "right", "both"])
    |> foreign_key_constraint(:location_id)
  end

  def complete_changeset(struct, attrs \\ %{}) do
    struct
    |> settings_changeset(attrs)
    |> cast(attrs, [:user_id, :questions, :scores, :started_at, :completed_at])
    |> validate_required([:user_id, :questions, :scores, :started_at, :completed_at])
  end

  #
  # Filters
  #

  def apply_filters(starting_query, filters) do
    Enum.reduce(filters, starting_query, fn {k, v}, query -> filter(query, k, v) end)
  end

  def filter(query, :id, id), do: Q.where(query, [l], l.id == ^id)
  def filter(query, :user, user), do: Q.where(query, [a], a.user_id == ^user.id)
  def filter(query, :user_id, user_id), do: Q.where(query, [l], l.user_id == ^user_id)
  def filter(query, :location_id, l_id), do: Q.where(query, [l], l.location_id == ^l_id)
  def filter(query, :setting, setting), do: Q.where(query, [l], l.setting == ^setting)
  def filter(query, :type, type), do: Q.where(query, [l], l.type == ^type)
  def filter(query, :preload, preloads), do: Q.preload(query, ^preloads)
  def filter(query, :order, :started_at_desc), do: Q.order_by(query, [a], [desc: a.started_at])
end
