defmodule Litcovers.Repo.Migrations.OverlayUrlToText do
  use Ecto.Migration

  def change do
    alter table(:overlays) do
      modify :url, :text
    end
  end
end
