defmodule Litcovers.Repo.Migrations.CreateCovers do
  use Ecto.Migration

  def change do
    create table(:covers) do
      add :cover_url, :string
      add :request_id, references(:requests, on_delete: :nothing)

      timestamps()
    end

    create index(:covers, [:request_id])
  end
end
