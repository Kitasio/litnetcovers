defmodule Litcovers.Sd.Prompt do
  use Ecto.Schema
  import Ecto.Changeset

  @derive {Jason.Encoder, only: [:id, :name, :realm, :sentiment, :type]}
  schema "prompts" do
    field :name, :string
    field :realm, Ecto.Enum, values: [:fantasy, :realism, :futurism]
    field :sentiment, Ecto.Enum, values: [:positive, :neutral, :negative]
    field :style_prompt, :string
    field :type, Ecto.Enum, values: [:object, :subject, :third_person]
    field :bad, :boolean
    field :image_url, :string

    has_many :requests, Litcovers.Media.Request

    timestamps()
  end

  @doc false
  def changeset(prompt, attrs) do
    prompt
    |> cast(attrs, [:name, :style_prompt, :type, :sentiment, :realm, :bad, :image_url])
    |> validate_required([:name, :style_prompt, :type, :sentiment, :realm])
  end
end
