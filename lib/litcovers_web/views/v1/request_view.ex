defmodule LitcoversWeb.V1.RequestView do
  use LitcoversWeb, :view

  def render("index.json", %{requests: requests}) do
    %{requests: requests}
  end

  def render("show.json", %{request: request}) do
    %{request: request}
  end

  def render("error.json", %{errors: errors}) do
    %{errors: errors}
  end
end
