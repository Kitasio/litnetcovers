defmodule Litcovers.Repo.Migrations.CreateEyes do
  use Ecto.Migration

  def change do
    create table(:eyes) do
      add :color, :string
      add :prompt, :string

      timestamps()
    end
  end
end
