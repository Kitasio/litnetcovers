defmodule LitcoversWeb.AdminLive.Index do
  use LitcoversWeb, :live_view

  alias Litcovers.Accounts
  alias Litcovers.Media

  def mount(_params, session, socket) do
    {
      :ok,
      socket
      |> assign(
        current_user: Accounts.get_user_by_session_token(session["user_token"]),
        tokens: Accounts.list_invite_tokens(),
        users: Accounts.list_regular_users(),
        requests: Media.list_uncompleted_requests(),
        title: "Admin page"
      )
    }
  end

  def handle_event("show_all_requests", %{}, socket) do
    {:noreply,
     socket
     |> assign(requests: Media.list_requests())}
  end

  def handle_event("create_token", %{}, socket) do
    Accounts.create_token()

    {:noreply,
     assign(
       socket,
       tokens: Accounts.list_invite_tokens()
     )}
  end

  def handle_event("delete_request", %{"request_id" => request_id}, socket) do
    request = Media.get_request!(request_id)
    Media.delete_request(request)

    {:noreply,
     assign(
       socket,
       requests: Media.list_uncompleted_requests()
     )}
  end

  def handle_event("delete_token", %{"token_id" => token_id}, socket) do
    token = Accounts.get_token!(token_id)
    Accounts.delete_token(token)

    {:noreply,
     assign(
       socket,
       tokens: Accounts.list_invite_tokens()
     )}
  end

  def handle_event("add_litcoins", %{"user_id" => user_id}, socket) do
    user = Accounts.get_user!(user_id)
    params = %{litcoins: user.litcoins + 1}
    Accounts.update_litcoins(user, params)

    {:noreply,
     assign(
       socket,
       users: Accounts.list_regular_users()
     )}
  end

  def handle_event("remove_litcoins", %{"user_id" => user_id}, socket) do
    user = Accounts.get_user!(user_id)
    params = %{litcoins: user.litcoins - 1}
    Accounts.update_litcoins(user, params)

    {:noreply,
     assign(
       socket,
       users: Accounts.list_regular_users()
     )}
  end

  def handle_event("add_requests", %{"user_id" => user_id}, socket) do
    user = Accounts.get_user!(user_id)
    params = %{max_requests: user.max_requests + 1}
    Accounts.update_max_requests(user, params)

    {:noreply,
     assign(
       socket,
       users: Accounts.list_regular_users()
     )}
  end

  def handle_event("remove_requests", %{"user_id" => user_id}, socket) do
    user = Accounts.get_user!(user_id)
    params = %{max_requests: user.max_requests - 1}
    Accounts.update_max_requests(user, params)

    {:noreply,
     assign(
       socket,
       users: Accounts.list_regular_users()
     )}
  end
end
