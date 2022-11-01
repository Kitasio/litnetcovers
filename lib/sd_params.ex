defmodule SDParams do
  @derive Jason.Encoder
  defstruct version: "c24bbf13332c755f9e1c8b3f10c7f438889145def57d554a74ea751dc5e3b509",
            input: %{
              prompt: "multicolor hyperspace",
              width: 512,
              height: 768,
              num_outputs: 1
            }
end
