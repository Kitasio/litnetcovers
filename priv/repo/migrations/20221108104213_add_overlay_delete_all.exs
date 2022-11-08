defmodule Litcovers.Repo.Migrations.AddOverlayDeleteAll do
  use Ecto.Migration

  def change do
    drop constraint(:overlays, :overlays_cover_id_fkey)

    alter table(:overlays) do
      modify :cover_id, references(:covers, on_delete: :delete_all)
    end
  end
end
