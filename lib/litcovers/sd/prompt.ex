defmodule Litcovers.Sd.Prompt do
  use Ecto.Schema
  import Ecto.Changeset

  schema "prompts" do
    field :name, :string
    field :realm, Ecto.Enum, values: [:fantasy, :realism, :futurism]
    field :sentiment, Ecto.Enum, values: [:positive, :neutral, :negative]
    field :style_prompt, :string
    field :type, Ecto.Enum, values: [:object, :subject, :third_person]

    timestamps()
  end

  @doc false
  def changeset(prompt, attrs) do
    prompt
    |> cast(attrs, [:name, :style_prompt, :type, :sentiment, :realm])
    |> validate_required([:name, :style_prompt, :type, :sentiment, :realm])
  end
end
