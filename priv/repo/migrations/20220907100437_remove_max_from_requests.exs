defmodule Litcovers.Repo.Migrations.RemoveMaxFromRequests do
  use Ecto.Migration

  def change do
    alter table(:requests) do
      remove :max
    end
  end
end
