defmodule Litcovers.Repo.Migrations.CreateTitleSplits do
  use Ecto.Migration

  def change do
    create table(:title_splits) do
      add :split, :string
      add :request_id, references(:requests, on_delete: :nothing)

      timestamps()
    end

    create index(:title_splits, [:request_id])
  end
end
