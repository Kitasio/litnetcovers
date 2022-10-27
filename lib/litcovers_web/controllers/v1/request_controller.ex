defmodule LitcoversWeb.V1.RequestController do
  use LitcoversWeb, :controller

  alias Litcovers.Media

  def index(conn, _params) do
    requests = Media.list_user_requests(conn.assigns.current_user)
    render(conn, :index, requests: requests)
  end

  defp get_female_or(nil), do: "female"
  defp get_female_or(value), do: value

  def create(conn, %{"request" => request_params})
      when not is_map_key(request_params, "prompt_id"),
      do: render(conn, :error, errors: "prompt_id was not specified")

  def create(conn, %{"request" => request_params})
      when not is_map_key(request_params, "amount"),
      do: render(conn, :error, errors: "amount was not specified")

  def create(conn, %{"request" => request_params}) do
    %{"prompt_id" => prompt_id, "amount" => amount} = request_params
    prompt = Litcovers.Sd.get_prompt!(prompt_id)
    gender = Map.get(request_params, "gender") |> get_female_or()

    cond do
      Media.user_requests_amount(conn.assigns.current_user) <
          conn.assigns.current_user.max_requests ->
        case Media.create_request(conn.assigns.current_user, prompt, request_params) do
          {:ok, request} ->
            request = Media.get_request_and_covers!(request.id)
            Task.start(fn -> Media.gen_covers(request, amount, gender) end)

            conn
            |> render(:show, request: request)

          {:error, %Ecto.Changeset{} = changeset} ->
            conn
            |> render(:error, errors: changeset)
        end

      true ->
        conn
        |> render(:error, errors: "max requests reached")
    end
  end

  def show(conn, %{"id" => id}) do
    request = Media.get_request_and_covers!(id)
    render(conn, :show, request: request)
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
