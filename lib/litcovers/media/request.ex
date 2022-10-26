defmodule Litcovers.Media.Request do
  use Ecto.Schema
  import Ecto.Changeset

  @derive {Jason.Encoder,
           only: [
             :id,
             :author,
             :title,
             :description,
             :completed,
             :covers,
             :user,
             :prompt
           ]}
  schema "requests" do
    field :author, :string
    field :description, :string
    field :title, :string
    field :completed, :boolean
    field :selected_cover, :integer

    belongs_to :user, Litcovers.Accounts.User
    belongs_to :prompt, Litcovers.Sd.Prompt
    has_many :covers, Litcovers.Media.Cover

    timestamps()
  end

  @doc false
  def changeset(request, attrs) do
    request
    |> cast(attrs, [
      :author,
      :title,
      :description,
      :selected_cover
    ])
    |> validate_required([:author, :title, :description])
    |> validate_length(:author, max: 30)
    |> validate_length(:title, max: 40)
    |> validate_length(:description, max: 600)
  end

  def admin_changeset(request, attrs) do
    request
    |> cast(attrs, [:author, :title, :description, :completed, :selected_cover])
  end

  def ai_changeset(request, attrs) do
    request
    |> cast(attrs, [:completed])
  end
end
