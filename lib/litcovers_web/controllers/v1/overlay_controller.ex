defmodule LitcoversWeb.V1.OverlayController do
  use LitcoversWeb, :controller

  alias Litcovers.Media
  alias Litcovers.Media.Overlay

  action_fallback LitcoversWeb.V1.FallbackController

  def index(conn, _params) do
    overlays = Media.list_overlays()
    render(conn, "index.json", overlays: overlays)
  end

  def create(conn, %{"overlay" => overlay_params})
      when not is_map_key(overlay_params, "cover_id"),
      do: render(conn, :error, errors: "`cover_id` was not specified")

  def create(conn, %{"overlay" => overlay_params}) do
    %{"cover_id" => cover_id} = overlay_params

    with {:ok, cover} <- Media.get_cover(cover_id),
         {:ok, %Overlay{} = overlay} <-
           Media.create_overlay(cover, overlay_params) do
      conn
      |> put_status(:created)
      |> render("show.json", overlay: overlay)
    end
  end

  def show(conn, %{"id" => id}) do
    with {:ok, overlay} <- Media.get_overlay(id) do
      render(conn, "show.json", overlay: overlay)
    end
  end

  def update(conn, %{"id" => id, "overlay" => overlay_params}) do
    overlay = Media.get_overlay!(id)

    with {:ok, %Overlay{} = overlay} <- Media.update_overlay(overlay, overlay_params) do
      render(conn, "show.json", overlay: overlay)
    end
  end

  def delete(conn, %{"id" => id}) do
    overlay = Media.get_overlay!(id)

    with {:ok, %Overlay{}} <- Media.delete_overlay(overlay) do
      send_resp(conn, :no_content, "")
    end
  end
end
