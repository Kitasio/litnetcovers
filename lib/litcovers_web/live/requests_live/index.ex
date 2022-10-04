defmodule LitcoversWeb.RequestsLive.Index do
  use LitcoversWeb, :live_view

  alias Litcovers.Accounts
  alias Litcovers.Media
  alias Litcovers.Media.Request

  def mount(_params, session, socket) do
    current_user = Accounts.get_user_by_session_token(session["user_token"])

    {
      :ok,
      socket
      |> assign(
        current_user: current_user,
        changeset: Media.change_request(%Request{}),
        placeholder: placeholder_or_empty(Media.get_random_placeholder() |> List.first()),
        title: "Мои обложки"
      )
    }
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
            img_urls = gen_covers(request.description, request)

            for url <- img_urls do
              image_params = %{"cover_url" => url}
              Media.create_cover(request, image_params)
            end

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

  def gen_covers(prompt, request) do
    oai_res =
      prompt
      |> BookCoverGenerator.description_to_cover_idea(System.get_env("OAI_TOKEN"))

    sd_res =
      oai_res
      |> BookCoverGenerator.diffuse(1, System.get_env("REPLICATE_TOKEN"))

    # artefacts =  Jason.encode!(sd_res) ++ book.sd_artefacts
    # AI.update_book_cover(book, %{sd_artefacts: artefacts})

    %{"output" => image_list} = sd_res
    img_urls = image_list |> BookCoverGenerator.save_to_spaces()

    Media.ai_update_request(request, %{completed: true})

    img_urls
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
