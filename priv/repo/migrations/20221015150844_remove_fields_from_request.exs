defmodule Litcovers.Repo.Migrations.RemoveFieldsFromRequest do
  use Ecto.Migration

  def change do
    alter table(:requests) do
      remove :status
      remove :genre
      remove :vibe
    end
  end
end
