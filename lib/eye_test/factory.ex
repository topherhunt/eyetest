# I was using ExMachina but found these hand-rolled factories simple to set up
# and more transparent vis-a-vis Ecto association handling.
defmodule EyeTest.Factory do
  alias EyeTest.Data.{User, Location, Assessment}

  def insert_user(params \\ %{}) do
    assert_no_keys_except(params, [:name, :email])
    uuid = random_uuid()

    User.insert!(%{
      name: params[:name] || "User #{uuid}",
      email: params[:email] || "user_#{uuid}@example.com"
    })
  end

  def insert_location(params \\ %{}) do
    assert_no_keys_except(params, [:user_id, :name, :cm_from_screen])
    uuid = random_uuid()

    Location.insert!(%{
      user_id: params[:user_id] || insert_user().id,
      name: params[:name] || "User #{uuid}",
      cm_from_screen: params[:cm_from_screen] || 200
    })
  end

  def insert_assessment(params \\ %{}) do
    assert_no_keys_except(params, [:user_id, :location_id, :which_eye, :current_light_level, :personal_notes, :other_notes, :questions, :scores, :started_at, :completed_at])

    Assessment.insert!(%{
      user_id: params[:user_id] || insert_user().id,
      location_id: params[:location_id] || insert_location().id,
      which_eye: params[:which_eye] || "left",
      current_light_level: params[:current_light_level] || 3,
      personal_notes: params[:personal_notes],
      other_notes: params[:other_notes],
      questions: params[:questions] || [build_question()],
      scores: params[:scores] || build_scores(),
      started_at: params[:started_at] || Timex.shift(Timex.now(), minutes: -20),
      completed_at: params[:completed_at] || Timex.shift(Timex.now(), minutes: -5)
    })
  end

  def build_question(params \\ %{}) do
    %{
      "size" => params[:size] || 45.3,
      "actual" => params[:actual] || "E",
      "guess" => params[:guess] || "F",
      "correct" => Map.get(params, :correct, true)
    }
  end

  def build_scores(params \\ %{}) do
    %{
      "smallest_correct" => params[:smallest_correct] || 41.9,
    }
  end

  def random_uuid do
    pool = String.codepoints("ABCDEFGHJKLMNPQRSTUVWXYZabcdefghijkmnopqrstuvwxyz123456789")
    Enum.map(1..6, fn _ -> Enum.random(pool) end) |> Enum.join()
  end

  #
  # Internal
  #

  defp assert_no_keys_except(params, allowed_keys) do
    keys = Enum.into(params, %{}) |> Map.keys()

    Enum.each(keys, fn key ->
      unless key in allowed_keys do
        raise "Unexpected key #{inspect(key)}."
      end
    end)
  end
end
