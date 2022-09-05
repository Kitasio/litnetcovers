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
    case Accounts.get_token_if_unused(user_params) do
      {:ok, token} ->

        case Accounts.register_user(user_params) do
          {:ok, user} ->
            Accounts.update_token(token, %{used: true})
            {:ok, _} =
              Accounts.deliver_user_confirmation_instructions(
                user,
                &Routes.user_confirmation_url(conn, :edit, &1)
              )

            conn
            |> put_flash(:info, "Вы успешно зарегистрировались")
            |> UserAuth.log_in_user(user)

          {:error, %Ecto.Changeset{} = changeset} ->
            render(conn, "new.html", changeset: changeset)
        end

      {:error, reason} ->
        conn
        |> put_flash(:error, reason)
        |> redirect(to: "/")
    end
  end
end
