defmodule Litcovers.Repo.Migrations.AddPromptToCover do
  use Ecto.Migration

  def change do
    alter table(:covers) do
      add :prompt, :text
    end
  end
end
