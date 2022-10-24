defmodule Litcovers.Repo.Migrations.RemoveIdeaAndRequestid do
  use Ecto.Migration

  def change do
    alter table(:prompts) do
      remove :oai_idea
      remove :request_id
    end
  end
end
