defmodule LitcoversWeb.PromptLive.Index do
  use LitcoversWeb, :live_view
  import Phoenix.Component

  alias Litcovers.Sd
  alias Litcovers.Sd.Prompt

  @impl true
  def mount(%{"locale" => locale} = _params, _session, socket) do
    IO.inspect(locale)

    {:ok,
     socket
     |> assign(:prompts, Sd.list_prompts())
     |> assign(:realm, nil)
     |> assign(:sentiment, nil)
     |> assign(:type, nil)
     |> assign(:locale, locale)}
  end

  @impl true
  def handle_params(params, _url, socket) do
    {:noreply, apply_action(socket, socket.assigns.live_action, params)}
  end

  defp apply_action(socket, :edit, %{"id" => id}) do
    socket
    |> assign(:page_title, "Edit Prompt")
    |> assign(:prompt, Sd.get_prompt!(id))
  end

  defp apply_action(socket, :new, _params) do
    socket
    |> assign(:page_title, "New Prompt")
    |> assign(:prompt, %Prompt{})
  end

  defp apply_action(socket, :index, _params) do
    socket
    |> assign(:page_title, "Listing Prompts")
    |> assign(:prompt, nil)
  end

  @impl true
  def handle_event("delete", %{"id" => id}, socket) do
    prompt = Sd.get_prompt!(id)
    {:ok, _} = Sd.delete_prompt(prompt)

    {:noreply, assign(socket, :prompts, list_prompts())}
  end

  def handle_event("all", %{}, socket) do
    {:noreply,
     socket
     |> assign(:realm, nil)
     |> assign(:sentiment, nil)
     |> assign(:type, nil)
     |> assign(:prompts, Sd.list_prompts())}
  end

  def handle_event("realm", %{"realm" => realm}, socket) do
    {:noreply,
     socket
     |> assign(
       realm: realm,
       prompts: list_prompts_where(realm, socket.assigns.sentiment, socket.assigns.type)
     )}
  end

  def handle_event("sentiment", %{"sentiment" => sentiment}, socket) do
    {:noreply,
     socket
     |> assign(
       sentiment: sentiment,
       prompts: list_prompts_where(socket.assigns.realm, sentiment, socket.assigns.type)
     )}
  end

  def handle_event("type", %{"type" => type}, socket) do
    {:noreply,
     socket
     |> assign(
       type: type,
       prompts: list_prompts_where(socket.assigns.realm, socket.assigns.sentiment, type)
     )}
  end

  defp list_prompts_where(realm, sentiment, type) do
    Sd.list_all_where(realm, sentiment, type)
  end

  defp list_prompts do
    Sd.list_all_where(nil, nil, nil)
  end
end
