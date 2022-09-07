defmodule LitcoversWeb.AdminLive.Index do
  use LitcoversWeb, :live_view

  alias Litcovers.Accounts

  def mount(_params, session, socket) do
    {
      :ok,
      socket
      |> assign(
        current_user: Accounts.get_user_by_session_token(session["user_token"]),
        tokens: Accounts.list_invite_tokens(),
        users: Accounts.list_regular_users(),
        title: "Admin page live"
      )
    }
  end

  def handle_event("create_token", %{}, socket) do
    Accounts.create_token()
    {:noreply, assign(
      socket,
      tokens: Accounts.list_invite_tokens()
    )}
  end

  def handle_event("delete_token", %{"token_id" => token_id}, socket) do
    token = Accounts.get_token!(token_id)
    Accounts.delete_token(token)
    {:noreply, assign(
      socket,
      tokens: Accounts.list_invite_tokens()
    )}
  end

  def handle_event("add_requests", %{"user_id" => user_id}, socket) do
    user = Accounts.get_user!(user_id)
    params = %{max_requests: user.max_requests + 1}
    Accounts.update_max_requests(user, params)
    {:noreply, assign(
      socket,
      users: Accounts.list_regular_users()
    )}
  end

  def handle_event("remove_requests", %{"user_id" => user_id}, socket) do
    user = Accounts.get_user!(user_id)
    params = %{max_requests: user.max_requests - 1}
    Accounts.update_max_requests(user, params)
    {:noreply, assign(
      socket,
      users: Accounts.list_regular_users()
    )}
  end
end
