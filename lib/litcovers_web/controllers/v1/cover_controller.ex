defmodule LitcoversWeb.V1.CoverController do
  use LitcoversWeb, :controller

  alias Litcovers.Media

  action_fallback LitcoversWeb.V1.FallbackController

  def show(conn, %{"id" => id}) do
    with {:ok, cover} <- Media.get_cover(id) do
      render(conn, "show.json", cover: cover)
    end
  end
end
