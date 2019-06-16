# I was using ExMachina but found these hand-rolled factories simple to set up
# and more transparent vis-a-vis Ecto association handling.
defmodule EyeTest.Factory do

  # def insert_user(params \\ %{}) do
  #   assert_no_keys_except(params, [:full_name, :email, :uuid])
  #   uuid = random_uuid()

  #   Accounts.insert_user!(%{
  #     full_name: params[:full_name] || "User #{uuid}",
  #     email: params[:email] || "user_#{uuid}@example.com",
  #     uuid: params[:uuid] || random_uuid()
  #   })
  # end

  # def insert_project(params \\ %{}) do
  #   assert_no_keys_except(params, [:name, :uuid])

  #   Projects.insert_project!(%{
  #     name: params[:name] || "Project #{random_uuid()}",
  #     uuid: params[:uuid] || random_uuid()
  #   })
  # end

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
