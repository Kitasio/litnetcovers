defmodule LitcoversWeb.V1.SessionView do
  use LitcoversWeb, :view

  def render("user_session_created.json", %{user: user, jwt: jwt, msg: msg}) do
    %{user: user, jwt: jwt, msg: msg}
  end

  def render("error.json", %{message: message}) do
    %{message: message}
  end
end
