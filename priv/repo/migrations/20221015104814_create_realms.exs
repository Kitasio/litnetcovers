defmodule Litcovers.Repo.Migrations.CreateRealms do
  use Ecto.Migration

  def change do
    create table(:realms) do
      add :title, :string

      timestamps()
    end
  end
end
