defmodule Litcovers.Media.Request do
  use Ecto.Schema
  import Ecto.Changeset

  schema "requests" do
    field :author, :string
    field :description, :string
    field :genre, :string
    field :max, :integer
    field :status, :string
    field :title, :string
    field :vibe, :string
    field :user_id, :id

    timestamps()
  end

  @doc false
  def changeset(request, attrs) do
    request
    |> cast(attrs, [:status, :max, :author, :title, :vibe, :description, :genre])
    |> validate_required([:status, :max, :author, :title, :vibe, :description, :genre])
  end
end
