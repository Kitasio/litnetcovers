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
end
