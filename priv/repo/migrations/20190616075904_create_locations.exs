defmodule EyeTest.Repo.Migrations.CreateLocations do
  use Ecto.Migration

  def change do
    create table(:locations) do
      add :user_id, references(:users, on_delete: :delete_all)
      add :name, :string
      add :cm_from_screen, :integer
      timestamps()
    end

    create index(:locations, [:user_id])
  end
end
