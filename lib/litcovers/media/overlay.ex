defmodule Litcovers.Media.Overlay do
  use Ecto.Schema
  import Ecto.Changeset

  @derive {Jason.Encoder, only: [:id, :url]}
  schema "overlays" do
    field :url, :string
    field :selected, :boolean
    belongs_to :cover, Litcovers.Media.Cover

    timestamps()
  end

  @doc false
  def changeset(overlay, attrs) do
    overlay
    |> cast(attrs, [:url, :selected])
    |> validate_required([:url])
  end
end
