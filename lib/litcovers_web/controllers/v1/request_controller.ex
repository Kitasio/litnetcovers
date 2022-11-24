defmodule LitcoversWeb.V1.RequestController do
  use LitcoversWeb, :controller

  alias Litcovers.Media
  alias Litcovers.Accounts

  def index(conn, _params) do
    requests = Media.list_user_requests(conn.assigns.current_user)
    render(conn, :index, requests: requests)
  end

  defp get_female_or(nil), do: "female"
  defp get_female_or("female"), do: "female"
  defp get_female_or("male"), do: "male"
  defp get_female_or(_any), do: "female"

  def create(conn, %{"request" => request_params})
      when not is_map_key(request_params, "prompt_id"),
      do: render(conn, :error, errors: "prompt_id was not specified")

  def create(conn, %{"request" => request_params}) do
    %{"prompt_id" => prompt_id} = request_params
    prompt = Litcovers.Sd.get_prompt!(prompt_id)

    cond do
      conn.assigns.current_user.litcoins > 0 ->
        case Media.create_request(conn.assigns.current_user, prompt, request_params) do
          {:ok, request} ->
            request = Media.get_request_and_covers!(request.id)
            Task.start(fn -> Media.gen_covers(request) end)

            params = %{litcoins: conn.assigns.current_user.litcoins - 1}

            Accounts.update_litcoins(
              conn.assigns.current_user,
              params
            )

            conn
            |> render(:show, request: request)

          {:error, %Ecto.Changeset{} = changeset} ->
            conn
            |> render(:error, errors: changeset)
        end

      true ->
        conn
        |> render(:error, errors: "No litcoins")
    end
  end

  def show(conn, %{"id" => id}) do
    request = Media.get_request_and_covers!(id)
    render(conn, :show, request: request)
  end

  def update(conn, %{"id" => id}) do
    cond do
      conn.assigns.current_user.litcoins > 0 ->
        request = Media.get_request_and_covers!(id)
        Task.start(fn -> Media.gen_more(request) end)

        params = %{litcoins: conn.assigns.current_user.litcoins - 1}

        Accounts.update_litcoins(
          conn.assigns.current_user,
          params
        )

        conn
        |> render(:show, request: request)

      true ->
        conn
        |> render(:error, errors: "No litcoins")
    end
  end
end
