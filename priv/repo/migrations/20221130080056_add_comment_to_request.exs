defmodule Litcovers.Repo.Migrations.AddCommentToRequest do
  use Ecto.Migration

  def change do
    alter table(:requests) do
      add :comment, :text
    end
  end
end
