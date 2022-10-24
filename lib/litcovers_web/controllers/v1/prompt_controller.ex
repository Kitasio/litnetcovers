defmodule LitcoversWeb.V1.PromptController do
  use LitcoversWeb, :controller

  alias Litcovers.Sd
  # alias Litcovers.Sd.Prompt

  def index(conn, _params) do
    prompts = Sd.list_prompts()
    render(conn, :index, prompts: prompts)
  end
end
