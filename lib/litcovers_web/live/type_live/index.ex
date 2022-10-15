defmodule LitcoversWeb.TypeLive.Index do
  use LitcoversWeb, :live_view

  alias Litcovers.Sd
  alias Litcovers.Sd.Type

  @impl true
  def mount(_params, _session, socket) do
    {:ok, assign(socket, :types, list_types())}
  end

  @impl true
  def handle_params(params, _url, socket) do
    {:noreply, apply_action(socket, socket.assigns.live_action, params)}
  end

  defp apply_action(socket, :edit, %{"id" => id}) do
    socket
    |> assign(:page_title, "Edit Type")
    |> assign(:type, Sd.get_type!(id))
  end

  defp apply_action(socket, :new, _params) do
    socket
    |> assign(:page_title, "New Type")
    |> assign(:type, %Type{})
  end

  defp apply_action(socket, :index, _params) do
    socket
    |> assign(:page_title, "Listing Types")
    |> assign(:type, nil)
  end

  @impl true
  def handle_event("delete", %{"id" => id}, socket) do
    type = Sd.get_type!(id)
    {:ok, _} = Sd.delete_type(type)

    {:noreply, assign(socket, :types, list_types())}
  end

  defp list_types do
    Sd.list_types()
  end
end
