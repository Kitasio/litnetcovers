defmodule LitcoversWeb.V1.OverlayView do
  use LitcoversWeb, :view
  alias LitcoversWeb.V1.OverlayView

  def render("index.json", %{overlays: overlays}) do
    %{data: render_many(overlays, OverlayView, "overlay.json")}
  end

  def render("show.json", %{overlay: overlay}) do
    %{data: render_one(overlay, OverlayView, "overlay.json")}
  end

  def render("overlay.json", %{overlay: overlay}) do
    %{
      id: overlay.id,
      url: overlay.url
    }
  end

  def render("error.json", %{errors: errors}) do
    %{error: errors}
  end
end
