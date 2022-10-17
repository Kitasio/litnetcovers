defmodule SDParams do
  @derive Jason.Encoder
  defstruct [
      version: "a9758cbfbd5f3c2094457d996681af52552901775aa2d6dd0b17fd15df959bef",
      input: %{
        prompt: "multicolor hyperspace",
        width: 512,
        height: 768,
        num_outputs: 1
      }
  ]
end
