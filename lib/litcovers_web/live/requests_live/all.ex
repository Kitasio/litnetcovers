defmodule LitcoversWeb.RequestsLive.All do
  use LitcoversWeb, :live_view
  import Phoenix.Component

  alias Litcovers.Media
  alias Litcovers.Sd

  import LitcoversWeb.UiComponents

  def mount(_params, _session, socket) do
    requests = Media.list_completed_requests(10)

    {:ok, socket |> assign(requests: requests, title: "All requests")}
  end

  def handle_event("show_all", %{}, socket) do
    requests = Media.list_completed_requests()

    {:noreply, socket |> assign(requests: requests)}
  end

  def handle_event("bad_prompt", %{"request_id" => request_id}, socket) do
    request = Media.get_request_and_covers!(request_id)
    params = %{bad: !request.prompt.bad}
    Sd.update_prompt(request.prompt, params)

    requests = Media.list_completed_requests()
    {:noreply, socket |> assign(requests: requests)}
  end

  def handle_event("select_cover", %{"cover_id" => cover_id, "request_id" => request_id}, socket) do
    params = %{selected_cover: cover_id}
    request = Media.get_request!(request_id)
    Media.update_request(request, params)

    {:noreply,
     assign(
       socket,
       requests: Media.list_completed_requests()
     )}
  end
end
