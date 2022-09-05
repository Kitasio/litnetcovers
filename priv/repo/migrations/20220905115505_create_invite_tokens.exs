defmodule Litcovers.Repo.Migrations.CreateInviteTokens do
  use Ecto.Migration

  def change do
    create table(:invite_tokens) do
      add :token, :uuid
      add :used, :boolean, default: false, null: false

      timestamps()
    end
  end
end
