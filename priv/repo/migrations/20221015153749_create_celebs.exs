defmodule Litcovers.Repo.Migrations.CreateCelebs do
  use Ecto.Migration

  def change do
    create table(:celebs) do
      add :famous, :boolean, default: false, null: false
      add :gender, :string
      add :name, :string

      timestamps()
    end
  end
end
