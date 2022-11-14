defmodule Litcovers.Repo.Migrations.AddImageUrlToPrompt do
  use Ecto.Migration

  def change do
    alter table(:prompts) do
      add :image_url, :text
    end
  end
end
