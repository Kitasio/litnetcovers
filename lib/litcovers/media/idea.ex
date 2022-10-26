defmodule Litcovers.Media.Idea do
  use Ecto.Schema
  import Ecto.Changeset

  @derive {Jason.Encoder, only: [:id, :idea]}
  schema "ideas" do
    field :idea, :string

    belongs_to :request, Litcovers.Media.Request

    timestamps()
  end

  @doc false
  def changeset(idea, attrs) do
    idea
    |> cast(attrs, [:idea])
    |> validate_required([:idea])
  end
end
