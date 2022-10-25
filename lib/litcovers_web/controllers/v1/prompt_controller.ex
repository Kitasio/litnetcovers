defmodule LitcoversWeb.V1.PromptController do
  use LitcoversWeb, :controller

  alias Litcovers.Sd
  alias Litcovers.Sd.Prompt

  def index(conn, %{"params" => params}) do
    realm = Map.get(params, "realm") |> get_enum_value(:realm)
    sentiment = Map.get(params, "sentiment") |> get_enum_value(:sentiment)
    type = Map.get(params, "type") |> get_enum_value(:type)

    prompts = Sd.list_all_where(realm, sentiment, type)
    render(conn, :index, prompts: prompts)
  end

  defp get_enum_value(nil, _field), do: nil

  defp get_enum_value(value, field) do
    mappings = Prompt |> Ecto.Enum.mappings(field)

    case Enum.find(mappings, fn x -> x == {String.to_atom(value), value} end) do
      nil ->
        nil

      value ->
        {_, field} = value
        field
    end
  end
end
