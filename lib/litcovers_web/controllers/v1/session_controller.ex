defmodule LitcoversWeb.V1.SessionController do
  use LitcoversWeb, :controller

  alias Litcovers.Accounts
  alias Litcovers.Accounts.User

  alias Litcovers.Guardian

  def create(conn, %{"email" => nil}) do
    conn
    |> put_status(401)
    |> render("error.json", message: "Wrong credentials")
  end

  def create(conn, %{"email" => email, "password" => password}) do
    case Accounts.get_user_by_email_and_password(email, password) do
      %User{} = user ->
        {:ok, jwt, _full_claims} = Guardian.encode_and_sign(user, %{}, ttl: {48, :weeks})
        msg = "Use it as a Bearer token in http requests"

        conn
        |> render("user_session_created.json", user: user, jwt: jwt, msg: msg)

      _ ->
        conn
        |> put_status(401)
        |> render("error.json", message: "Wrong credentials")
    end
  end
end
