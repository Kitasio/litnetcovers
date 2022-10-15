defmodule LitcoversWeb.SentimentLive.Index do
  use LitcoversWeb, :live_view

  alias Litcovers.Sd
  alias Litcovers.Sd.Sentiment

  @impl true
  def mount(_params, _session, socket) do
    {:ok, assign(socket, :sentiments, list_sentiments())}
  end

  @impl true
  def handle_params(params, _url, socket) do
    {:noreply, apply_action(socket, socket.assigns.live_action, params)}
  end

  defp apply_action(socket, :edit, %{"id" => id}) do
    socket
    |> assign(:page_title, "Edit Sentiment")
    |> assign(:sentiment, Sd.get_sentiment!(id))
  end

  defp apply_action(socket, :new, _params) do
    socket
    |> assign(:page_title, "New Sentiment")
    |> assign(:sentiment, %Sentiment{})
  end

  defp apply_action(socket, :index, _params) do
    socket
    |> assign(:page_title, "Listing Sentiments")
    |> assign(:sentiment, nil)
  end

  @impl true
  def handle_event("delete", %{"id" => id}, socket) do
    sentiment = Sd.get_sentiment!(id)
    {:ok, _} = Sd.delete_sentiment(sentiment)

    {:noreply, assign(socket, :sentiments, list_sentiments())}
  end

  defp list_sentiments do
    Sd.list_sentiments()
  end
end
