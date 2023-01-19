defmodule Litcovers.Repo.Migrations.AddWidthAndHeightToRequest do
  use Ecto.Migration

  def change do
    alter table(:requests) do
      add :width, :integer
      add :height, :integer
    end
  end
end
