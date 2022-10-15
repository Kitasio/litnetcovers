defmodule Litcovers.Sd.Realm do
  use Ecto.Schema
  import Ecto.Changeset

  schema "realms" do
    field :title, :string

    timestamps()
  end

  @doc false
  def changeset(realm, attrs) do
    realm
    |> cast(attrs, [:title])
    |> validate_required([:title])
  end
end
