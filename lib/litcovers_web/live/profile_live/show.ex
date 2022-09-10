defmodule LitcoversWeb.ProfileLive.Show do
  use LitcoversWeb, :live_view

  import LitcoversWeb.UiComponents
  alias Litcovers.Accounts
  alias Litcovers.Media

  def mount(params, session, socket) do
    %{"request_id" => request_id} = params
    request = Media.get_request_and_covers!(request_id)

    {
      :ok,
      socket
      |> assign(
        current_user: Accounts.get_user_by_session_token(session["user_token"]),
        request: request,
        title: "Создание обложки"
      )
    }
  end
end
