defmodule Litcovers.Repo.Migrations.AddMaxRequestsToUser do
  use Ecto.Migration

  def change do
    alter table(:users) do
      add :max_requests, :integer, default: 1, null: false
    end
  end
end
