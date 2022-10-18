defmodule Litcovers.Media.Request do
  use Ecto.Schema
  import Ecto.Changeset

  schema "requests" do
    field :author, :string
    field :description, :string
    field :title, :string
    field :completed, :boolean
    field :selected_cover, :integer
    field :style_prompt, :string
    field :final_prompt, :string
    field :type, Ecto.Enum, values: [:object, :subject, :third_person]
    field :eye_prompt, :string
    field :hair_prompt, :string
    field :gender, Ecto.Enum, values: [:male, :female]

    belongs_to :user, Litcovers.Accounts.User
    has_many :covers, Litcovers.Media.Cover

    timestamps()
  end

  @doc false
  def changeset(request, attrs) do
    request
    |> cast(attrs, [:author, :title, :description, :selected_cover, :style_prompt, :type, :eye_prompt, :hair_prompt, :gender])
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
    |> cast(attrs, [:completed, :final_prompt])
  end
end
