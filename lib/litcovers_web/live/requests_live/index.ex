defmodule LitcoversWeb.RequestsLive.Index do
  use LitcoversWeb, :live_view
  import Phoenix.Component

  alias Phoenix.LiveView.JS
  alias Litcovers.Accounts
  alias Litcovers.Media
  alias Litcovers.Media.Request
  alias Litcovers.Sd

  def types() do
    [
      %{name: :object, label: "СЕТТИНГ"},
      %{name: nil, label: nil},
      %{name: :subject, label: "ПЕРСОНАЖ"}
    ]
  end

  def realms() do
    [
      %{name: :fantasy, label: "ФЭНТЕЗИ - ПРОШЛОЕ"},
      %{name: :realism, label: "РЕАЛЬНОСТЬ - НАСТОЯЩЕЕ"},
      %{name: :futurism, label: "ФАНТАСТИКА - БУДУЩЕЕ"}
    ]
  end

  def sentiments do
    [
      %{name: :positive, label: "тёплая - Светлая"},
      %{name: :neutral, label: "Натуральная - нейтральная"},
      %{name: :negative, label: "Брутальная - мрачная"}
    ]
  end

  def mount(_params, session, socket) do
    current_user = Accounts.get_user_by_session_token(session["user_token"])

    style_prompts = Sd.list_all_where(:fantasy, :positive, :object)
    prompt = style_prompts |> List.first()

    stage = get_stage(0)

    {
      :ok,
      socket
      |> assign(
        current_user: current_user,
        changeset: Media.change_request(%Request{}),
        placeholder: placeholder_or_empty(Media.get_random_placeholder() |> List.first()),
        stage: stage,
        realms: realms(),
        realm: :fantasy,
        types: types(),
        type: :object,
        sentiments: sentiments(),
        sentiment: :positive,
        gender: :female,
        style_prompts: style_prompts,
        style_prompt: prompt.style_prompt,
        prompt_id: prompt.id
      )
    }
  end

  def handle_event("set_stage", %{"stage" => stage}, socket) do
    stage = get_stage(stage |> String.to_integer())
    socket = assign(socket, stage: stage)
    {:noreply, socket}
  end

  def handle_event("change_gender", %{"gender" => gender}, socket) do
    socket =
      socket
      |> assign(gender: gender)

    {:noreply, socket}
  end

  def handle_event("next", %{"value" => value}, socket) do
    case socket.assigns.stage.id do
      0 ->
        stage = get_stage(socket.assigns.stage.id + 1)

        socket =
          socket
          |> assign(
            stage: stage,
            type: value
          )

        {:noreply, socket}

      1 ->
        stage = get_stage(socket.assigns.stage.id + 1)

        socket =
          socket
          |> assign(
            stage: stage,
            realm: value
          )

        {:noreply, socket}

      2 ->
        stage = get_stage(socket.assigns.stage.id + 1)

        style_prompts = Sd.list_all_where(socket.assigns.realm, value, socket.assigns.type)
        random_prompt = style_prompts |> Enum.random()

        socket =
          socket
          |> assign(
            stage: stage,
            sentiment: value,
            style_prompts: style_prompts,
            style_prompt: random_prompt.style_prompt,
            prompt_id: random_prompt.id
          )

        {:noreply, socket}

      3 ->
        # stage = get_stage(socket.assigns.stage.id + 1)
        # prompt = Sd.get_prompt!(value)
        #
        # socket =
        #   socket
        #   |> assign(stage: stage, style_prompt: prompt.style_prompt, prompt_id: prompt.id)

        {:noreply, socket}
    end
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
      socket.assigns.current_user.litcoins > 0 ->
        %{"prompt_id" => prompt_id} = request_params
        prompt = Litcovers.Sd.get_prompt!(prompt_id)

        case Media.create_request(socket.assigns.current_user, prompt, request_params) do
          {:ok, request} ->
            Task.start(fn ->
              Media.gen_covers(request)
            end)

            params = %{litcoins: socket.assigns.current_user.litcoins - 1}

            Accounts.update_litcoins(
              socket.assigns.current_user,
              params
            )

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
         |> put_flash(:error, "У вас недостаточно литкоинов.")
         |> redirect(to: Routes.live_path(socket, LitcoversWeb.ProfileLive.Index))}
    end
  end

  def insert_tr(link, label) do
    tr =
      "tr:w-512,h-768,oi-vin.png,ow-512,oh-768,f-jpg,pr-true:ot-#{label},ots-30,otp-5_5_25_5,ofo-bottom,otc-fafafa"

    uri = link |> URI.parse()
    %URI{host: host, path: path} = uri

    {filename, list} = path |> String.split("/") |> List.pop_at(-1)
    folder = list |> List.last()
    bucket = "soulgenesis"

    case host do
      "ik.imagekit.io" ->
        Path.join(["https://", host, bucket, folder, tr, filename])

      _ ->
        link
    end
  end

  def stage_nav(assigns) do
    ~H"""
    <div class="mt-3 flex justify-center text-xs sm:text-base">
      <%= for stage <- stages() do %>
        <%= if stage.id <= assigns.stage do %>
          <%= if stage.id == assigns.stage do %>
            <button class="uppercase text-zinc-100 font-light">
              <%= stage.name %>
            </button>
          <% else %>
            <button
              phx-click={
                JS.push("set_stage") |> JS.transition("opacity-0 translate-y-6", to: "#stage-box")
              }
              phx-value-stage={stage.id}
              class="uppercase text-zinc-400 hover:text-zinc-100 font-light"
            >
              <%= stage.name %>
            </button>
          <% end %>
          <span class="last:hidden pb-1 mx-2 text-zinc-400">></span>
        <% end %>
      <% end %>
    </div>
    """
  end

  def img_box(assigns) do
    if assigns.value == nil do
      ~H"""
      <div></div>
      """
    else
      src = default_img(assigns.src)

      label = assigns.label |> String.upcase()
      url = insert_tr(src, label)
      assigns = assign(assigns, :url, url)

      ~H"""
      <div
        id={"#{@url}"}
        class="overflow-hidden"
        x-data={"{ showImage: false, imageUrl: '#{@url}' }"}
        x-init={"console.log('#{@url}')"}
      >
        <img
          x-show="showImage"
          x-transition.duration.500ms
          x-bind:src="imageUrl"
          x-on:load="showImage = true"
          alt={assigns.label}
          class="w-full h-full object-cover aspect-cover cursor-pointer transition duration-500 ease-out hover:scale-[1.02] hover:saturate-[1.3]"
          phx-click={JS.push("next") |> JS.transition("opacity-0 translate-y-6", to: "#stage-box")}
          phx-value-value={assigns.value}
        />
      </div>
      """
    end
  end

  defp default_img(img) do
    if img == nil do
      "https://ik.imagekit.io/soulgenesis/litnet/realm_fantasy.jpg"
    else
      img
    end
  end

  def gender_picker(assigns) do
    ~H"""
    <div class="my-10 flex justify-center w-full gap-5">
      <button class="link text-xl" phx-click="change_gender" phx-value-gender={:female}>
        ЖЕНЩИНА
      </button>
      <button class="link text-xl" phx-click="change_gender" phx-value-gender={:male}>
        МУЖЧИНА
      </button>
    </div>
    """
  end

  def stage_box(assigns) do
    ~H"""
    <div class="grid md:grid-cols-3">
      <%= render_slot(@inner_block) %>
    </div>
    """
  end

  def stage_msg(assigns) do
    ~H"""
    <div class="text-center my-10">
      <h1 class="text-sm sm:text-base lg:text-xl font-light uppercase">
        <%= assigns.msg %>
      </h1>
    </div>
    """
  end

  defp stages do
    [
      %{
        id: 0,
        name: "Тип обложки",
        msg: "Какой тип обложки будет более подходящим для вашего произведения?"
      },
      %{id: 1, name: "Мир", msg: "Какой мир ближе к вашей книге?"},
      %{id: 2, name: "Атмосфера", msg: "Какая атмосфера царит в вашем мире?"},
      # %{id: 3, name: "Стиль", msg: "Какой стиль обложки вам больше нравится?"},
      %{id: 3, name: nil, msg: nil}
    ]
  end

  defp get_stage(id) do
    Enum.find(stages(), fn stage -> stage.id == id end)
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
