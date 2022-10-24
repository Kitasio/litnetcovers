defmodule Litcovers.Repo.Migrations.RemovePromptFieldsFromRequest do
  use Ecto.Migration

  def change do
    alter table(:requests) do
      remove :style_prompt
      remove :final_prompt
      remove :type
      remove :eye_prompt
      remove :hair_prompt
      remove :gender
    end
  end
end
