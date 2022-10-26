defmodule Litcovers.Media.TitleSplit do
  use Ecto.Schema
  import Ecto.Changeset

  @derive {Jason.Encoder, only: [:id, :split]}
  schema "title_splits" do
    field :split, :string

    belongs_to :request, Litcovers.Media.Request

    timestamps()
  end

  @doc false
  def changeset(title_split, attrs) do
    title_split
    |> cast(attrs, [:split])
    |> validate_required([:split])
  end
end
