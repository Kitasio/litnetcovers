defmodule Litcovers.Sd.Type do
  use Ecto.Schema
  import Ecto.Changeset

  schema "types" do
    field :title, :string

    timestamps()
  end

  @doc false
  def changeset(type, attrs) do
    type
    |> cast(attrs, [:title])
    |> validate_required([:title])
  end
end
