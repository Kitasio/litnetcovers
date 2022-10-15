defmodule Litcovers.Repo.Migrations.RemoveFieldsFromPrompt do
  use Ecto.Migration

  def change do
    alter table(:prompts) do
      remove :final_prompt
      remove :request_id
    end
  end
end
