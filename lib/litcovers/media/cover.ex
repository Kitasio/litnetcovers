defmodule Litcovers.Media.Cover do
  use Ecto.Schema
  import Ecto.Changeset

  @derive {Jason.Encoder, only: [:id, :prompt, :cover_url, :overlays]}
  schema "covers" do
    field :cover_url, :string
    field :prompt, :string

    belongs_to :request, Litcovers.Media.Request
    has_many :overlays, Litcovers.Media.Overlay, on_delete: :delete_all

    timestamps()
  end

  @doc false
  def changeset(cover, attrs) do
    cover
    |> cast(attrs, [:cover_url, :prompt])
    |> validate_required([:cover_url])
  end
end
