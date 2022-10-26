defmodule SDParams do
  @derive Jason.Encoder
  defstruct version: "a826166bdfbd1c12981a2e914120aa8c19ab2b5474ff8c70f4e2923e6d6596cc",
            input: %{
              prompt: "multicolor hyperspace",
              width: 512,
              height: 768,
              num_outputs: 1
            }
end
