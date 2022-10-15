defmodule LitcoversWeb.SentimentLive.FormComponent do
  use LitcoversWeb, :live_component

  alias Litcovers.Sd

  @impl true
  def update(%{sentiment: sentiment} = assigns, socket) do
    changeset = Sd.change_sentiment(sentiment)

    {:ok,
     socket
     |> assign(assigns)
     |> assign(:changeset, changeset)}
  end

  @impl true
  def handle_event("validate", %{"sentiment" => sentiment_params}, socket) do
    changeset =
      socket.assigns.sentiment
      |> Sd.change_sentiment(sentiment_params)
      |> Map.put(:action, :validate)

    {:noreply, assign(socket, :changeset, changeset)}
  end

  def handle_event("save", %{"sentiment" => sentiment_params}, socket) do
    save_sentiment(socket, socket.assigns.action, sentiment_params)
  end

  defp save_sentiment(socket, :edit, sentiment_params) do
    case Sd.update_sentiment(socket.assigns.sentiment, sentiment_params) do
      {:ok, _sentiment} ->
        {:noreply,
         socket
         |> put_flash(:info, "Sentiment updated successfully")
         |> push_redirect(to: socket.assigns.return_to)}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign(socket, :changeset, changeset)}
    end
  end

  defp save_sentiment(socket, :new, sentiment_params) do
    case Sd.create_sentiment(sentiment_params) do
      {:ok, _sentiment} ->
        {:noreply,
         socket
         |> put_flash(:info, "Sentiment created successfully")
         |> push_redirect(to: socket.assigns.return_to)}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign(socket, changeset: changeset)}
    end
  end
end
