defmodule EyeTest.Repo.Migrations.CreateUsers do
  use Ecto.Migration

  def change do
    create table(:users) do
      add :name, :string
      add :email, :string
      add :auth0_uid, :string
      add :last_signed_in_at, :naive_datetime
      timestamps()
    end

    create unique_index(:users, [:email])
    create unique_index(:users, [:auth0_uid])
  end
end
