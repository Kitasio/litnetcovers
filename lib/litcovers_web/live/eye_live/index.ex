defmodule LitcoversWeb.EyeLive.Index do
  use LitcoversWeb, :live_view

  alias Litcovers.Character
  alias Litcovers.Character.Eye

  @impl true
  def mount(_params, _session, socket) do
    {:ok, assign(socket, :eyes, list_eyes())}
  end

  @impl true
  def handle_params(params, _url, socket) do
    {:noreply, apply_action(socket, socket.assigns.live_action, params)}
  end

  defp apply_action(socket, :edit, %{"id" => id}) do
    socket
    |> assign(:page_title, "Edit Eye")
    |> assign(:eye, Character.get_eye!(id))
  end

  defp apply_action(socket, :new, _params) do
    socket
    |> assign(:page_title, "New Eye")
    |> assign(:eye, %Eye{})
  end

  defp apply_action(socket, :index, _params) do
    socket
    |> assign(:page_title, "Listing Eyes")
    |> assign(:eye, nil)
  end

  @impl true
  def handle_event("delete", %{"id" => id}, socket) do
    eye = Character.get_eye!(id)
    {:ok, _} = Character.delete_eye(eye)

    {:noreply, assign(socket, :eyes, list_eyes())}
  end

  defp list_eyes do
    Character.list_eyes()
  end
end
