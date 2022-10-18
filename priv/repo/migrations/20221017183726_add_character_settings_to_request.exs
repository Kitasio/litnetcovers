defmodule Litcovers.Repo.Migrations.AddCharacterSettingsToRequest do
  use Ecto.Migration

  def change do
    alter table(:requests) do
      add :eye_prompt, :string
      add :hair_prompt, :string
      add :gender, :string
    end
  end
end
