defmodule Litcovers.Media.Request do
  use Ecto.Schema
  import Ecto.Changeset

  @derive {Jason.Encoder,
           only: [
             :id,
             :completed,
             :author,
             :title,
             :description,
             :final_desc,
             :prompt,
             :ideas,
             :title_splits,
             :covers,
             :character_gender,
             :user
           ]}
  schema "requests" do
    field :author, :string
    field :description, :string
    field :title, :string
    field :completed, :boolean
    field :selected_cover, :integer
    field :character_gender, :string
    field :final_desc, :string

    belongs_to :user, Litcovers.Accounts.User
    belongs_to :prompt, Litcovers.Sd.Prompt
    has_many :covers, Litcovers.Media.Cover, on_delete: :delete_all
    has_many :ideas, Litcovers.Media.Idea, on_delete: :delete_all
    has_many :title_splits, Litcovers.Media.TitleSplit, on_delete: :delete_all

    timestamps()
  end

  @doc false
  def changeset(request, attrs) do
    request
    |> cast(attrs, [
      :author,
      :title,
      :description,
      :selected_cover,
      :character_gender
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
    |> cast(attrs, [:completed, :final_desc])
  end
end
