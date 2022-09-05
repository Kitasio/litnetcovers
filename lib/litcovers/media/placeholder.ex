defmodule Litcovers.Media.Placeholder do
  use Ecto.Schema
  import Ecto.Changeset

  schema "placeholders" do
    field :author, :string
    field :description, :string
    field :title, :string
    field :vibe, :string

    timestamps()
  end

  @doc false
  def changeset(placeholder, attrs) do
    placeholder
    |> cast(attrs, [:author, :title, :vibe, :description])
    |> validate_required([:author, :title, :vibe, :description])
  end
end
