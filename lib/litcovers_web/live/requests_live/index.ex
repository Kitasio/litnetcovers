defmodule LitcoversWeb.RequestsLive.Index do
  use LitcoversWeb, :live_view

  alias Litcovers.Accounts
  alias Litcovers.Media
  alias Litcovers.Media.Request

  def mount(_params, session, socket) do
    current_user = Accounts.get_user_by_session_token(session["user_token"])
    realms = [:fantasy, :realism, :futurism]

    {
      :ok,
      socket
      |> assign(
        current_user: current_user,
        changeset: Media.change_request(%Request{}),
        placeholder: placeholder_or_empty(Media.get_random_placeholder() |> List.first()),
        realms: realms,
        realm: :realism,
        title: "Мои обложки"
      )
    }
  end

  def handle_event("select_realm", %{"realm" => realm}, socket) do
    {:noreply, assign(socket, realm: realm)}
  end

  def handle_event("validate", %{"request" => params}, socket) do
    changeset =
      %Request{}
      |> Media.change_request(params)
      |> Map.put(:action, :insert)

    {:noreply, assign(socket, changeset: changeset)}
  end

  def handle_event("save", %{"request" => request_params}, socket) do
    cond do
      Media.user_requests_amount(socket.assigns.current_user) <
          socket.assigns.current_user.max_requests ->
        case Media.create_request(socket.assigns.current_user, request_params) do
          {:ok, request} ->
            Task.start(fn ->
              Media.gen_covers(request.description, request)
            end)

            {:noreply,
             socket
             |> put_flash(:info, "Ваша заявка подана.")
             |> redirect(to: Routes.live_path(socket, LitcoversWeb.ProfileLive.Index))}

          {:error, %Ecto.Changeset{} = changeset} ->
            placeholder = placeholder_or_empty(Media.get_random_placeholder() |> List.first())
            {:noreply, assign(socket, changeset: changeset, placeholder: placeholder)}
        end

      true ->
        {:noreply,
         socket
         |> put_flash(:error, "Вы уже подали максимальное количество заявок")
         |> redirect(to: Routes.live_path(socket, LitcoversWeb.ProfileLive.Index))}
    end
  end

  def placeholder_or_empty(nil),
    do: %{
      author: "Герман Мелвилл",
      title: "Моби Дик",
      description:
        "История о мести человека гигантскому белому киту. После того, как кит нападает и убивает его друга, мужчина, Ахав, посвящает свою жизнь выслеживанию и убийству этого существа. В романе затрагиваются темы борьбы добра со злом, Бога и человеческой способности к дикости.",
      vibe: "приключения, опасность, одержимость"
    }

  def placeholder_or_empty(placeholder), do: placeholder

  def vibes do
    [
      "Приключения",
      "Страсть",
      "Веселье",
      "Ностальгия",
      "Романтика",
      "Симпатия",
      "Тревожность",
      "Пугающий",
      "Таинственный",
      "Элегантный",
      "Красивый",
      "Захватывающий",
      "Жуткий",
      "Скандальный",
      "Завораживающий",
      "Чувственный",
      "Темный",
      "Опасный",
      "Манящий",
      "Свирепый",
      "Гламурный",
      "Модный",
      "Культовый",
      "Интригующий",
      "Чокнутый",
      "Роскошный",
      "Волшебный",
      "Современный",
      "Эпатажный",
      "Игривый",
      "Популярный",
      "Новый",
      "Изворотливый",
      "Рискованный",
      "Скандальный",
      "Утонченный",
      "Злой",
      "Шокирующий"
    ]
  end

  def genres do
    [
      "Любовные романы",
      "Молодёжная проза",
      "Фанфик",
      "Боевик",
      "Фэнтези",
      "Фантастика",
      "Попаданцы",
      "Детективы",
      "Триллеры",
      "ЛитРПГ",
      "Исторический роман",
      "Женский роман",
      "Проза",
      "Мистика/Ужасы",
      "Уся"
    ]
  end
end
