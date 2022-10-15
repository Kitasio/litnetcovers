defmodule Litcovers.Character.Eye do
  use Ecto.Schema
  import Ecto.Changeset

  schema "eyes" do
    field :color, :string
    field :prompt, :string

    timestamps()
  end

  @doc false
  def changeset(eye, attrs) do
    eye
    |> cast(attrs, [:color, :prompt])
    |> validate_required([:color, :prompt])
  end
end
