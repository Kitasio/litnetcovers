defmodule Litcovers.Repo.Migrations.AddFinalDescToRequest do
  use Ecto.Migration

  def change do
    alter table(:requests) do
      add :final_desc, :text
    end
  end
end
