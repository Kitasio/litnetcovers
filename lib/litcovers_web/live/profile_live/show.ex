defmodule LitcoversWeb.ProfileLive.Show do
  use LitcoversWeb, :live_view
  import Phoenix.Component

  import LitcoversWeb.UiComponents
  alias Litcovers.Accounts
  alias Litcovers.Media

  def mount(params, session, socket) do
    if connected?(socket), do: CoverGen.Create.subscribe()
    %{"request_id" => request_id, "locale" => locale} = params
    Gettext.put_locale(locale)
    request = Media.get_request_and_covers!(request_id)

    {
      :ok,
      socket
      |> assign(
        current_user: Accounts.get_user_by_session_token(session["user_token"]),
        request: request,
        title: gettext("Cover creation")
      )
    }
  end

  def handle_event("select_cover", %{"cover_id" => _cover_id}, socket) do
    # params = %{selected_cover: cover_id}
    # Media.update_request(socket.assigns.request, params)

    {:noreply, socket}
  end

  def insert_image_high_res(link) do
    uri = link |> URI.parse()
    %URI{host: host, path: path} = uri

    {filename, list} = path |> String.split("/") |> List.pop_at(-1)
    bucket = list |> List.last()
    transformation = "tr:q-100"

    case host do
      "ik.imagekit.io" ->
        Path.join(["https://", host, bucket, transformation, filename])

      _ ->
        link
    end
  end

  def get_cover(id) do
    %{cover_url: url} = Media.get_cover!(id)
    url = insert_image_high_res(url)
    %HTTPoison.Response{body: body} = HTTPoison.get!(url)
    Base.encode64(body)
  end
end
