defmodule Litcovers.Repo.Migrations.AddCoverIdeaToRequest do
  use Ecto.Migration

  def change do
    alter table(:requests) do
      add :cover_idea, :string
    end
  end
end
