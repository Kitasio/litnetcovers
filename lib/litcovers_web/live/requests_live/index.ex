defmodule LitcoversWeb.RequestsLive.Index do
  use LitcoversWeb, :live_view

  alias Litcovers.Accounts
  alias Litcovers.Media
  alias Litcovers.Media.Request
  alias Litcovers.Character
  alias Litcovers.Sd

  def mount(_params, session, socket) do
    current_user = Accounts.get_user_by_session_token(session["user_token"])
    realms = [:fantasy, :realism, :futurism]
    types = [:object, :subject, :third_person]
    sentiments = [:positive, :neutral, :negative]

    eyes = Character.list_eyes()
    eye = eyes |> List.first()
    eye_prompt = eye.prompt

    hair = Character.list_hair()
    h = hair |> List.first()
    hair_prompt = h.prompt

    style_prompts = Sd.list_all_where(:fantasy, :positive, :object)
    prompt = style_prompts |> List.first()
    style_prompt = prompt.style_prompt

    character_prompt = get_character_prompt(:male, eye_prompt, hair_prompt)

    {
      :ok,
      socket
      |> assign(
        current_user: current_user,
        changeset: Media.change_request(%Request{}),
        placeholder: placeholder_or_empty(Media.get_random_placeholder() |> List.first()),
        realms: realms,
        realm: :fantasy,
        types: types,
        type: :object,
        sentiments: sentiments,
        sentiment: :positive,
        eyes: eyes,
        eye_prompt: eye_prompt,
        hair: hair,
        hair_prompt: hair_prompt,
        gender: :male,
        style_prompts: style_prompts,
        style_prompt: style_prompt,
        character_prompt: character_prompt,
        title: "Мои обложки"
      )
    }
  end

  def get_celeb_name(gender, is_famous) do
    case Character.get_random_celeb(gender, is_famous) do
      nil ->
        ""

      celeb ->
        celeb.name
    end
  end

  def get_character_prompt(gender, eye_prompt, hair_prompt) do
    famous_celeb = get_celeb_name(gender, true)
    not_famous_celeb = get_celeb_name(gender, false)

    "#{not_famous_celeb} as #{famous_celeb}, #{eye_prompt}, #{hair_prompt}"
  end

  def list_prompts(realm, sentiment, type) do
    style_prompts = Sd.list_all_where(realm, sentiment, type)

    if Enum.empty?(style_prompts) do
      {:error, "No prompts found"}
    else
      prompt = style_prompts |> List.first()
      style_prompt = prompt.style_prompt
      {:ok, style_prompts, style_prompt}
    end
  end

  def handle_event("select_type", %{"type" => type}, socket) do
    case list_prompts(socket.assigns.realm, socket.assigns.sentiment, type) do
      {:ok, style_prompts, style_prompt} ->
        {:noreply,
         assign(socket, type: type, style_prompt: style_prompt, style_prompts: style_prompts)}

      {:error, _} ->
        {:noreply, assign(socket, type: type)}
    end
  end

  def handle_event("select_realm", %{"realm" => realm}, socket) do
    case list_prompts(realm, socket.assigns.sentiment, socket.assigns.type) do
      {:ok, style_prompts, style_prompt} ->
        {:noreply,
         assign(socket, realm: realm, style_prompt: style_prompt, style_prompts: style_prompts)}

      {:error, _} ->
        {:noreply, assign(socket, realm: realm)}
    end
  end

  def handle_event("select_eye", %{"eye" => eye}, socket) do
    {:noreply,
     assign(socket,
       eye_prompt: eye,
       character_prompt:
         get_character_prompt(
           socket.assigns.gender,
           eye,
           socket.assigns.hair_prompt
         )
     )}
  end

  def handle_event("select_hair", %{"hair" => hair}, socket) do
    {:noreply,
     assign(socket,
       hair_prompt: hair,
       character_prompt:
         get_character_prompt(
           socket.assigns.gender,
           socket.assigns.eye_prompt,
           hair
         )
     )}
  end

  def handle_event("select_gender", %{"gender" => gender}, socket) do
    {:noreply,
     assign(socket,
       gender: gender,
       character_prompt:
         get_character_prompt(
           gender,
           socket.assigns.eye_prompt,
           socket.assigns.hair_prompt
         )
     )}
  end

  def handle_event("select_sentiment", %{"sentiment" => sentiment}, socket) do
    case list_prompts(socket.assigns.realm, sentiment, socket.assigns.type) do
      {:ok, style_prompts, style_prompt} ->
        {:noreply,
         assign(socket,
           sentiment: sentiment,
           style_prompt: style_prompt,
           style_prompts: style_prompts
         )}

      {:error, _} ->
        {:noreply, assign(socket, sentiment: sentiment)}
    end
  end

  def handle_event("select_prompt", %{"prompt" => prompt}, socket) do
    {:noreply, assign(socket, style_prompt: prompt)}
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
