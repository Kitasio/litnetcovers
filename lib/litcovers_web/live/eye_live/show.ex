defmodule LitcoversWeb.EyeLive.Show do
  use LitcoversWeb, :live_view
  import Phoenix.Component

  alias Litcovers.Character

  @impl true
  def mount(_params, _session, socket) do
    {:ok, socket}
  end

  @impl true
  def handle_params(%{"id" => id}, _, socket) do
    {:noreply,
     socket
     |> assign(:page_title, page_title(socket.assigns.live_action))
     |> assign(:eye, Character.get_eye!(id))}
  end

  defp page_title(:show), do: "Show Eye"
  defp page_title(:edit), do: "Edit Eye"
end
