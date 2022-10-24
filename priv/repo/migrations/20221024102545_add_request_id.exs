defmodule Litcovers.Repo.Migrations.AddRequestId do
  use Ecto.Migration

  def change do
    alter table(:prompts) do
      add :request_id, references(:requests, on_delete: :nothing)
    end
  end
end
