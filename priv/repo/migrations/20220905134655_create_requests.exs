defmodule Litcovers.Repo.Migrations.CreateRequests do
  use Ecto.Migration

  def change do
    create table(:requests) do
      add :status, :string
      add :max, :integer, default: 1
      add :author, :string
      add :title, :string
      add :vibe, :string
      add :description, :text
      add :genre, :string
      add :user_id, references(:users, on_delete: :nothing)

      timestamps()
    end

    create index(:requests, [:user_id])
  end
end
