defmodule Litcovers.Accounts.Token do
  use Ecto.Schema
  import Ecto.Changeset

  schema "invite_tokens" do
    field :token, Ecto.UUID
    field :used, :boolean, default: false

    timestamps()
  end

  @doc false
  def changeset(token, attrs) do
    token
    |> cast(attrs, [:token, :used])
    |> validate_required([:token, :used])
  end
end
