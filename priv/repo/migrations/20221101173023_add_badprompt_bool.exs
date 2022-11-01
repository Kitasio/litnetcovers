defmodule Litcovers.Repo.Migrations.AddBadpromptBool do
  use Ecto.Migration

  def change do
    alter table(:prompts) do
      add :bad, :boolean, default: false, null: false
    end
  end
end
