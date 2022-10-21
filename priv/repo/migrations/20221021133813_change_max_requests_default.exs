defmodule Litcovers.Repo.Migrations.ChangeMaxRequestsDefault do
  use Ecto.Migration

  def change do
    alter table(:users) do
      modify :max_requests, :integer, default: 0, null: false
    end
  end
end
