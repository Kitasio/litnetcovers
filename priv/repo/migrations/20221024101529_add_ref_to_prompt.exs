defmodule Litcovers.Repo.Migrations.AddRefToPrompt do
  use Ecto.Migration

  def change do
    alter table(:requests) do
      add :prompt_id, references(:prompts, on_delete: :nothing)
    end
  end
end
