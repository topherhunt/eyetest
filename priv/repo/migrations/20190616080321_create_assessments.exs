defmodule EyeTest.Repo.Migrations.CreateAssessments do
  use Ecto.Migration

  def change do
    create table(:assessments) do
      add :user_id, references(:users, on_delete: :delete_all)
      add :location_id, references(:locations, on_delete: :nilify_all)
      # "left", "right", "both"
      add :which_eye, :string
      # 1 to 5
      add :current_light_level, :integer
      # notes on how I'm feeling that day, etc. - written in by user
      add :personal_notes, :string
      # flags to be automatically added if I'm tweaking test behavior
      add :other_notes, :string
      add :questions, :jsonb
      add :scores, :jsonb
      timestamps()
      # the moment the first question is shown, the assessment begins
      add :started_at, :utc_datetime
      # the moment the last question was answered, the assessment ends
      add :completed_at, :utc_datetime
    end

    create index(:assessments, [:user_id])
    create index(:assessments, [:location_id])
    create index(:assessments, [:which_eye])
  end
end
