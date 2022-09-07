defmodule Litcovers.Repo.Migrations.AddBookCoverUrlToRequests do
  use Ecto.Migration

  def change do
    alter table(:requests) do
      add :book_cover_url, :string
    end
  end
end
