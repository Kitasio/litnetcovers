defmodule LitcoversWeb.AdminLive.Show do
  use LitcoversWeb, :live_view

  alias Litcovers.Accounts
  alias Litcovers.Media

  def mount(params, session, socket) do
    %{"request_id" => request_id} = params
    request = Media.get_request!(request_id)

    {
      :ok,
      socket
      |> assign(
        current_user: Accounts.get_user_by_session_token(session["user_token"]),
        request: request,
        title: "Request page"
      )
    }
  end
end
