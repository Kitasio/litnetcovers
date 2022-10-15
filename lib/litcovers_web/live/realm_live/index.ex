defmodule LitcoversWeb.RealmLive.Index do
  use LitcoversWeb, :live_view

  alias Litcovers.Sd
  alias Litcovers.Sd.Realm

  @impl true
  def mount(_params, _session, socket) do
    {:ok, assign(socket, :realms, list_realms())}
  end

  @impl true
  def handle_params(params, _url, socket) do
    {:noreply, apply_action(socket, socket.assigns.live_action, params)}
  end

  defp apply_action(socket, :edit, %{"id" => id}) do
    socket
    |> assign(:page_title, "Edit Realm")
    |> assign(:realm, Sd.get_realm!(id))
  end

  defp apply_action(socket, :new, _params) do
    socket
    |> assign(:page_title, "New Realm")
    |> assign(:realm, %Realm{})
  end

  defp apply_action(socket, :index, _params) do
    socket
    |> assign(:page_title, "Listing Realms")
    |> assign(:realm, nil)
  end

  @impl true
  def handle_event("delete", %{"id" => id}, socket) do
    realm = Sd.get_realm!(id)
    {:ok, _} = Sd.delete_realm(realm)

    {:noreply, assign(socket, :realms, list_realms())}
  end

  defp list_realms do
    Sd.list_realms()
  end
end
