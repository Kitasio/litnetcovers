defmodule LitcoversWeb.UserRegistrationController do
  use LitcoversWeb, :controller

  alias Litcovers.Accounts
  alias Litcovers.Accounts.User
  alias LitcoversWeb.UserAuth

  def new(conn, _params) do
    changeset = Accounts.change_user_registration(%User{})
    render(conn, "new.html", changeset: changeset)
  end

  def create(conn, %{"user" => user_params}) do
    case Accounts.register_user(user_params) do
      {:ok, user} ->
        {:ok, _} =
          Accounts.deliver_user_confirmation_instructions(
            user,
            &Routes.user_confirmation_url(conn, :edit, conn.assigns.locale, &1)
          )

        conn
        |> put_flash(:info, gettext("Use the link we sent you to confirm your email address."))
        |> UserAuth.log_in_user(user)

      {:error, %Ecto.Changeset{} = changeset} ->
        render(conn, "new.html", changeset: changeset)
    end
  end
end
