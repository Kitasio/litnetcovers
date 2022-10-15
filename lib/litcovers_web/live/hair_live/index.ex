defmodule LitcoversWeb.HairLive.Index do
  use LitcoversWeb, :live_view

  alias Litcovers.Character
  alias Litcovers.Character.Hair

  @impl true
  def mount(_params, _session, socket) do
    {:ok, assign(socket, :hair_collection, list_hair())}
  end

  @impl true
  def handle_params(params, _url, socket) do
    {:noreply, apply_action(socket, socket.assigns.live_action, params)}
  end

  defp apply_action(socket, :edit, %{"id" => id}) do
    socket
    |> assign(:page_title, "Edit Hair")
    |> assign(:hair, Character.get_hair!(id))
  end

  defp apply_action(socket, :new, _params) do
    socket
    |> assign(:page_title, "New Hair")
    |> assign(:hair, %Hair{})
  end

  defp apply_action(socket, :index, _params) do
    socket
    |> assign(:page_title, "Listing Hair")
    |> assign(:hair, nil)
  end

  @impl true
  def handle_event("delete", %{"id" => id}, socket) do
    hair = Character.get_hair!(id)
    {:ok, _} = Character.delete_hair(hair)

    {:noreply, assign(socket, :hair_collection, list_hair())}
  end

  defp list_hair do
    Character.list_hair()
  end
end
