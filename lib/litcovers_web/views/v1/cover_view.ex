defmodule LitcoversWeb.V1.CoverView do
  use LitcoversWeb, :view
  alias LitcoversWeb.V1.CoverView

  def render("show.json", %{cover: cover}) do
    # %{data: render_one(cover, CoverView, "cover.json")}
    %{data: cover}
  end

  def render("cover.json", %{cover: cover}) do
    %{
      id: cover.id,
      url: cover.cover_url
    }
  end

  def render("error.json", %{errors: errors}) do
    %{error: errors}
  end
end
