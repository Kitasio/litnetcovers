defmodule LitcoversWeb.CelebLive.Index do
  use LitcoversWeb, :live_view
  import Phoenix.Component

  alias Litcovers.Character
  alias Litcovers.Character.Celeb

  @impl true
  def mount(_params, _session, socket) do
    {:ok, assign(socket, :celebs, list_celebs())}
  end

  @impl true
  def handle_params(params, _url, socket) do
    {:noreply, apply_action(socket, socket.assigns.live_action, params)}
  end

  defp apply_action(socket, :edit, %{"id" => id}) do
    socket
    |> assign(:page_title, "Edit Celeb")
    |> assign(:celeb, Character.get_celeb!(id))
  end

  defp apply_action(socket, :new, _params) do
    socket
    |> assign(:page_title, "New Celeb")
    |> assign(:celeb, %Celeb{})
  end

  defp apply_action(socket, :index, _params) do
    socket
    |> assign(:page_title, "Listing Celebs")
    |> assign(:celeb, nil)
  end

  @impl true
  def handle_event("delete", %{"id" => id}, socket) do
    celeb = Character.get_celeb!(id)
    {:ok, _} = Character.delete_celeb(celeb)

    {:noreply, assign(socket, :celebs, list_celebs())}
  end

  defp list_celebs do
    Character.list_celebs()
  end
end
