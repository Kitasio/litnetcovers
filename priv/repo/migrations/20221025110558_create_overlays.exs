defmodule Litcovers.Repo.Migrations.CreateOverlays do
  use Ecto.Migration

  def change do
    create table(:overlays) do
      add :url, :string
      add :cover_id, references(:covers, on_delete: :nothing)

      timestamps()
    end

    create index(:overlays, [:cover_id])
  end
end
