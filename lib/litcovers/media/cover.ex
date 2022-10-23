defmodule Litcovers.Media.Cover do
  use Ecto.Schema
  import Ecto.Changeset

  @derive {Jason.Encoder, only: [:id, :cover_url]}
  schema "covers" do
    field :cover_url, :string

    belongs_to :request, Litcovers.Media.Request

    timestamps()
  end

  @doc false
  def changeset(cover, attrs) do
    cover
    |> cast(attrs, [:cover_url])
    |> validate_required([:cover_url])
  end
end
