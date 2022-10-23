defmodule TupleEncoder do
  alias Jason.Encoder
  require Protocol
  Protocol.derive(Jason.Encoder, Ecto.Changeset, only: [:errors])

  defimpl Encoder, for: Tuple do
    def encode(data, options) when is_tuple(data) do
      data
      |> Tuple.to_list()
      |> Encoder.List.encode(options)
    end
  end
end
