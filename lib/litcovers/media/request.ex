defmodule Litcovers.Media.Request do
  use Ecto.Schema
  import Ecto.Changeset

  schema "requests" do
    field :author, :string
    field :description, :string
    field :genre, :string
    field :status, :string
    field :title, :string
    field :vibe, :string
    field :completed, :boolean
    field :selected_cover, :integer
    
    belongs_to :user, Litcovers.Accounts.User
    has_many :covers, Litcovers.Media.Cover

    timestamps()
  end

  @doc false
  def changeset(request, attrs) do
    request
    |> cast(attrs, [:author, :title, :vibe, :description, :genre, :selected_cover])
    |> validate_required([:author, :title, :vibe, :description, :genre])
    |> validate_length(:author, max: 30)
    |> validate_length(:title, max: 40)
    |> validate_length(:vibe, max: 50)
    |> validate_length(:description, max: 600)
  end

  def admin_changeset(request, attrs) do
    request
    |> cast(attrs, [:status, :author, :title, :vibe, :description, :genre, :completed, :selected_cover])
  end

  def ai_changeset(request, attrs) do
    request
    |> cast(attrs, [:completed])
  end
end
