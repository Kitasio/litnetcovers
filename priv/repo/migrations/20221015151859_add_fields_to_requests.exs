defmodule Litcovers.Repo.Migrations.AddFieldsToRequests do
  use Ecto.Migration

  def change do
    alter table(:requests) do
      add :style_prompt, :text
      add :final_prompt, :text
    end
  end
end
