defmodule Litcovers.Repo.Migrations.CreateIdeas do
  use Ecto.Migration

  def change do
    create table(:ideas) do
      add :idea, :string
      add :request_id, references(:requests, on_delete: :nothing)

      timestamps()
    end

    create index(:ideas, [:request_id])
  end
end
