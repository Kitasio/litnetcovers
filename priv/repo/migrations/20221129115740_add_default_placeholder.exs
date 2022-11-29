defmodule Litcovers.Repo.Migrations.AddDefaultPlaceholder do
  use Ecto.Migration

  def change do
    alter table(:prompts) do
      modify :image_url, :text, default: "https://via.placeholder.com/512x768"
    end
  end
end
