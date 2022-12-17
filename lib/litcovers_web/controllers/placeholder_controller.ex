defmodule LitcoversWeb.PlaceholderController do
  use LitcoversWeb, :controller

  alias Litcovers.Media
  alias Litcovers.Media.Placeholder

  def index(conn, _params) do
    placeholders = Media.list_placeholders()
    render(conn, "index.html", placeholders: placeholders)
  end

  def new(conn, _params) do
    changeset = Media.change_placeholder(%Placeholder{})
    render(conn, "new.html", changeset: changeset)
  end

  def create(conn, %{"placeholder" => placeholder_params}) do
    case Media.create_placeholder(placeholder_params) do
      {:ok, placeholder} ->
        conn
        |> put_flash(:info, "Placeholder created successfully.")
        |> redirect(to: Routes.placeholder_path(conn, conn.assigns.locale, :show, placeholder))

      {:error, %Ecto.Changeset{} = changeset} ->
        render(conn, "new.html", changeset: changeset)
    end
  end

  def show(conn, %{"id" => id}) do
    placeholder = Media.get_placeholder!(id)
    render(conn, "show.html", placeholder: placeholder)
  end

  def edit(conn, %{"id" => id}) do
    placeholder = Media.get_placeholder!(id)
    changeset = Media.change_placeholder(placeholder)
    render(conn, "edit.html", placeholder: placeholder, changeset: changeset)
  end

  def update(conn, %{"id" => id, "placeholder" => placeholder_params}) do
    placeholder = Media.get_placeholder!(id)

    case Media.update_placeholder(placeholder, placeholder_params) do
      {:ok, placeholder} ->
        conn
        |> put_flash(:info, "Placeholder updated successfully.")
        |> redirect(to: Routes.placeholder_path(conn, conn.assigns.locale, :show, placeholder))

      {:error, %Ecto.Changeset{} = changeset} ->
        render(conn, "edit.html", placeholder: placeholder, changeset: changeset)
    end
  end

  def delete(conn, %{"id" => id}) do
    placeholder = Media.get_placeholder!(id)
    {:ok, _placeholder} = Media.delete_placeholder(placeholder)

    conn
    |> put_flash(:info, "Placeholder deleted successfully.")
    |> redirect(to: Routes.placeholder_path(conn, conn.assigns.locale, :index))
  end
end
