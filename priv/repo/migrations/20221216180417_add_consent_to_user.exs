defmodule Litcovers.Repo.Migrations.AddConsentToUser do
  use Ecto.Migration

  def change do
    alter table(:users) do
      add :consent, :boolean, null: false, default: false
    end
  end
end
