defmodule Litcovers.Repo.Migrations.CreateSentiments do
  use Ecto.Migration

  def change do
    create table(:sentiments) do
      add :title, :string

      timestamps()
    end
  end
end
