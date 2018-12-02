defmodule Hello.Repo.Migrations.CreateInnChecks do
  use Ecto.Migration

  def change do
    create table(:inn_checks) do
      add :inn, :string
      add :result, :boolean, default: false, null: false

      timestamps()
    end

  end
end
