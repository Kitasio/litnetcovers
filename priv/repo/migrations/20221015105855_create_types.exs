defmodule Litcovers.Repo.Migrations.CreateTypes do
  use Ecto.Migration

  def change do
    create table(:types) do
      add :title, :string

      timestamps()
    end
  end
end
