defmodule Litcovers.Character.Celeb do
  use Ecto.Schema
  import Ecto.Changeset

  schema "celebs" do
    field :famous, :boolean, default: false
    field :gender, Ecto.Enum, values: [:male, :female]
    field :name, :string

    timestamps()
  end

  @doc false
  def changeset(celeb, attrs) do
    celeb
    |> cast(attrs, [:famous, :gender, :name])
    |> validate_required([:famous, :gender, :name])
  end
end
