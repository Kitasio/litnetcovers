defmodule LitcoversWeb.RequestController do
  use LitcoversWeb, :controller

  alias Litcovers.Media
  alias Litcovers.Media.Request

  def index(conn, _params) do
    requests = Media.list_user_requests(conn.assigns.current_user)
    render(conn, "index.html", requests: requests)
  end

  def new(conn, _params) do
    changeset = Media.change_request(%Request{})
    placeholder = placeholder_or_empty(Media.get_random_placeholder() |> List.first())
    render(conn, "new.html", changeset: changeset, placeholder: placeholder)
  end

  def placeholder_or_empty(nil),
    do: %{
      author: "Герман Мелвилл",
      title: "Моби Дик",
      description: "История о мести человека гигантскому белому киту. После того, как кит нападает и убивает его друга, мужчина, Ахав, посвящает свою жизнь выслеживанию и убийству этого существа. В романе затрагиваются темы борьбы добра со злом, Бога и человеческой способности к дикости.",
      vibe: "приключения, опасность, одержимость"
    }

  def placeholder_or_empty(placeholder), do: placeholder

  def create(conn, %{"request" => request_params}) do
    cond do
      Media.user_requests_amount(conn.assigns.current_user) <
          conn.assigns.current_user.max_requests ->
        case Media.create_request(conn.assigns.current_user, request_params) do
          {:ok, request} ->
            conn
            |> put_flash(:info, "Request created successfully.")
            |> redirect(to: Routes.request_path(conn, :show, request))

          {:error, %Ecto.Changeset{} = changeset} ->
            placeholder = Media.get_random_placeholder() |> List.first()
            render(conn, "new.html", changeset: changeset, placeholder: placeholder)
        end

      true ->
        conn
        |> put_flash(:error, "Вы подали максимальное количество заявок")
        |> redirect(to: Routes.request_path(conn, :index))
    end
  end

  def show(conn, %{"id" => id}) do
    request = Media.get_request!(id)
    render(conn, "show.html", request: request)
  end

  def edit(conn, %{"id" => id}) do
    request = Media.get_request!(id)
    changeset = Media.change_request(request)
    render(conn, "edit.html", request: request, changeset: changeset)
  end

  def update(conn, %{"id" => id, "request" => request_params}) do
    request = Media.get_request!(id)

    case Media.update_request(request, request_params) do
      {:ok, request} ->
        conn
        |> put_flash(:info, "Request updated successfully.")
        |> redirect(to: Routes.request_path(conn, :show, request))

      {:error, %Ecto.Changeset{} = changeset} ->
        render(conn, "edit.html", request: request, changeset: changeset)
    end
  end

  def delete(conn, %{"id" => id}) do
    request = Media.get_request!(id)
    {:ok, _request} = Media.delete_request(request)

    conn
    |> put_flash(:info, "Request deleted successfully.")
    |> redirect(to: Routes.request_path(conn, :index))
  end
end
