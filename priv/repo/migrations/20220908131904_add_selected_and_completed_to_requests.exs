defmodule Litcovers.Repo.Migrations.AddSelectedAndCompletedToRequests do
  use Ecto.Migration

  def change do
    alter table(:requests) do
      add :completed, :boolean, default: false, null: false
      add :selected_cover, :integer
    end
  end
end
