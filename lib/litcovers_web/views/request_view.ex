defmodule LitcoversWeb.RequestView do
  use LitcoversWeb, :view

  def render("show.json", %{request: request}) do
    %{request: request}
  end
end
