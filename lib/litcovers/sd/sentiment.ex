defmodule Litcovers.Sd.Sentiment do
  use Ecto.Schema
  import Ecto.Changeset

  schema "sentiments" do
    field :title, :string

    timestamps()
  end

  @doc false
  def changeset(sentiment, attrs) do
    sentiment
    |> cast(attrs, [:title])
    |> validate_required([:title])
  end
end
