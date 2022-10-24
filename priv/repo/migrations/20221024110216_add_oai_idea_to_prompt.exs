defmodule Litcovers.Repo.Migrations.AddOaiIdeaToPrompt do
  use Ecto.Migration

  def change do
    alter table(:prompts) do
      add :oai_idea, :string
    end
  end
end
