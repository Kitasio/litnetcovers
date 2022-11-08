defmodule Litcovers.Repo.Migrations.AddRequestDeleteAll do
  use Ecto.Migration

  def change do
    drop constraint(:title_splits, :title_splits_request_id_fkey)

    alter table(:title_splits) do
      modify :request_id, references(:requests, on_delete: :delete_all)
    end

    drop constraint(:ideas, :ideas_request_id_fkey)

    alter table(:ideas) do
      modify :request_id, references(:requests, on_delete: :delete_all)
    end

    drop constraint(:covers, :covers_request_id_fkey)

    alter table(:covers) do
      modify :request_id, references(:requests, on_delete: :delete_all)
    end
  end
end
