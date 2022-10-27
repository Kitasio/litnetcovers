defmodule Litcovers.Repo.Migrations.AddCharGenderToRequest do
  use Ecto.Migration

  def change do
    alter table(:requests) do
      add :character_gender, :string, default: "female", null: false
    end
  end
end
