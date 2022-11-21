defmodule SDParams do
  @derive Jason.Encoder
  defstruct version: "9936c2001faa2194a261c01381f90e65261879985476014a0a37a334593a05eb",
            input: %{
              prompt: "multicolor hyperspace",
              width: 512,
              height: 768,
              num_outputs: 1
            }
end
