defmodule Litcovers.Repo.Migrations.CreatePrompts do
  use Ecto.Migration

  def change do
    create table(:prompts) do
      add :name, :string
      add :style_prompt, :text
      add :final_prompt, :text
      add :type, :string
      add :sentiment, :string
      add :realm, :string
      add :request_id, references(:requests, on_delete: :nothing)

      timestamps()
    end

    create index(:prompts, [:request_id])
  end
end
