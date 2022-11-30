defmodule Litcovers.Repo.Migrations.AddOptionalFieldsToUsers do
  use Ecto.Migration

  def change do
    alter table(:users) do
      add :phone, :string
      add :name, :string
      add :position, :string
      modify :litcoins, :integer, default: 1, null: false
    end
  end
end
