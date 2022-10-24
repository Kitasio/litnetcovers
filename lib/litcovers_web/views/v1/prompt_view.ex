defmodule LitcoversWeb.V1.PromptView do
  use LitcoversWeb, :view

  def render("index.json", %{prompts: prompts}) do
    %{prompts: prompts}
  end

  def render("error.json", %{errors: errors}) do
    %{errors: errors}
  end
end
