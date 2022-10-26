defmodule Litcovers.Repo.Migrations.RemoveCoverIdea do
  use Ecto.Migration

  def change do
    alter table(:requests) do
      remove :cover_idea, :string
    end
  end
end
