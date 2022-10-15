defmodule Litcovers.Repo.Migrations.CreateHair do
  use Ecto.Migration

  def change do
    create table(:hair) do
      add :name, :string
      add :prompt, :string

      timestamps()
    end
  end
end
