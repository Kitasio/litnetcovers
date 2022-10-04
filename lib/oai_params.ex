defmodule OAIParams do
  @derive Jason.Encoder
  defstruct [
      prompt: "Hello mr robot",
      max_tokens: 255,
      model: "text-davinci-002",
      temperature: 1,
  ]
end
