defmodule Litcovers.Repo.Migrations.AddSelectedBoolOverlays do
  use Ecto.Migration

  def change do
    alter table(:overlays) do
      add :selected, :boolean, default: false, null: false
    end
  end
end
