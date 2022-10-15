defmodule LitcoversWeb.SentimentLive.Show do
  use LitcoversWeb, :live_view

  alias Litcovers.Sd

  @impl true
  def mount(_params, _session, socket) do
    {:ok, socket}
  end

  @impl true
  def handle_params(%{"id" => id}, _, socket) do
    {:noreply,
     socket
     |> assign(:page_title, page_title(socket.assigns.live_action))
     |> assign(:sentiment, Sd.get_sentiment!(id))}
  end

  defp page_title(:show), do: "Show Sentiment"
  defp page_title(:edit), do: "Edit Sentiment"
end
