defmodule LitcoversWeb.ProfileLive.Index do
  use LitcoversWeb, :live_view

  import LitcoversWeb.UiComponents

  alias Litcovers.Accounts
  alias Litcovers.Media

  def mount(_params, session, socket) do
    current_user = Accounts.get_user_by_session_token(session["user_token"])

    {
      :ok,
      socket
      |> assign(
        current_user: current_user,
        requests: Media.list_user_requests(current_user),
        title: "Мои обложки"
      )
    }
  end
end
