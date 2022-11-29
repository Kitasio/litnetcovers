defmodule OAIParams do
  @derive Jason.Encoder
  defstruct prompt: "Hello mr robot",
            max_tokens: 255,
            model: "text-davinci-003",
            temperature: 1
end
