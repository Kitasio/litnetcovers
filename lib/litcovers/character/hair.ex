defmodule Litcovers.Character.Hair do
  use Ecto.Schema
  import Ecto.Changeset

  schema "hair" do
    field :name, :string
    field :prompt, :string

    timestamps()
  end

  @doc false
  def changeset(hair, attrs) do
    hair
    |> cast(attrs, [:name, :prompt])
    |> validate_required([:name, :prompt])
  end
end
