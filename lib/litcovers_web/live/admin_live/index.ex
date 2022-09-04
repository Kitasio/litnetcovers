defmodule LitcoversWeb.AdminLive.Index do
  use LitcoversWeb, :live_view

  alias Litcovers.Accounts

  def mount(_params, session, socket) do
    {
      :ok,
      socket
      |> assign(
        current_user: Accounts.get_user_by_session_token(session["user_token"]),
        title: "Admin page live",
      )
    }
  end

  def render(assigns) do
    ~H"""
    <h1><%= @title %></h1>
    """
  end
end
