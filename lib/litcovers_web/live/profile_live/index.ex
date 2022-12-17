defmodule LitcoversWeb.ProfileLive.Index do
  use LitcoversWeb, :live_view
  import Phoenix.Component

  import LitcoversWeb.UiComponents

  alias Litcovers.Accounts
  alias Litcovers.Media

  def mount(%{"locale" => locale} = _params, session, socket) do
    Gettext.put_locale(locale)
    if connected?(socket), do: Media.subscribe()
    current_user = Accounts.get_user_by_session_token(session["user_token"])
    requests = Media.list_user_requests(current_user)

    {
      :ok,
      socket
      |> assign(
        current_user: current_user,
        requests: requests,
        locale: locale,
        title: gettext("My covers")
      )
    }
  end

  def handle_info({:gen_complete, _request}, socket) do
    requests = Media.list_user_requests(socket.assigns.current_user)
    {:noreply, socket |> assign(requests: requests)}
  end

  def get_cover(id) do
    %{cover_url: url} = Media.get_cover!(id)
    url
  end
end
