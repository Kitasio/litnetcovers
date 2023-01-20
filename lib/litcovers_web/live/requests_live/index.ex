defmodule LitcoversWeb.RequestsLive.Index do
  use LitcoversWeb, :live_view
  import Phoenix.Component
  import LitcoversWeb.UiComponents

  alias CoverGen.Create
  alias Phoenix.LiveView.JS
  alias Litcovers.Accounts
  alias Litcovers.Media
  alias Litcovers.Media.Request
  alias Litcovers.Sd

  def types() do
    [
      %{name: :object, label: gettext("Setting")},
      %{name: nil, label: nil},
      %{name: :subject, label: gettext("Character")}
    ]
  end

  def realms() do
    [
      %{name: :fantasy, label: gettext("Fantasy - Past")},
      %{name: :realism, label: gettext("Realism - Present")},
      %{name: :futurism, label: gettext("Futurism - Future")}
    ]
  end

  def sentiments do
    [
      %{name: :positive, label: gettext("Warm - Bright")},
      %{name: :neutral, label: gettext("Natural - Neutral")},
      %{name: :negative, label: gettext("Brutal - Dark")}
    ]
  end

  def mount(%{"locale" => locale} = _params, session, socket) do
    if connected?(socket), do: CoverGen.Create.subscribe()
    Gettext.put_locale(locale)
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
        prompt_id: prompt.id,
        locale: locale,
        lit_ai: true,
        aspect_ratio: "cover",
        width: 512,
        height: 768,
        img_url: nil,
        request_id: nil,
        request_completed: false
      )
    }
  end

  defp get_width_and_height("cover") do
    {512, 768}
  end

  defp get_width_and_height("square") do
    {512, 512}
  end

  def handle_info({:gen_complete, request}, socket) do
    request = Media.get_request_and_covers!(request.id)
    cover = request.covers |> List.first()

    {:noreply,
     socket
     |> assign(
       img_url: cover.cover_url,
       request_id: request.id,
       request_completed: request.completed
     )}
  end

  def handle_event(
        "aspect-ratio-change",
        %{"aspect_ratio" => aspect_ratio},
        socket
      ) do
    {width, height} = get_width_and_height(aspect_ratio)
    {:noreply, assign(socket, aspect_ratio: aspect_ratio, width: width, height: height)}
  end

  def handle_event("toggle-change", %{"toggle" => toggle}, socket) do
    toggle = if toggle == "1", do: true, else: false

    {:noreply, assign(socket, :lit_ai, toggle)}
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

        socket =
          socket
          |> assign(
            stage: stage,
            sentiment: value,
            style_prompts: style_prompts
          )

        {:noreply, socket}

      3 ->
        prompt = Sd.get_prompt!(value)

        socket =
          socket
          |> assign(style_prompt: prompt.style_prompt, prompt_id: prompt.id)

        {:noreply, socket}

      4 ->
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
    %{"prompt_id" => prompt_id} = request_params
    prompt = Litcovers.Sd.get_prompt!(prompt_id)

    case Media.create_request(socket.assigns.current_user, prompt, request_params) do
      {:ok, request} ->
        Task.start(fn ->
          Create.new(request)
        end)

        socket = socket |> assign(request_id: request.id, request_completed: false, img_url: nil)

        {:noreply, socket}

      {:error, %Ecto.Changeset{} = changeset} ->
        IO.inspect(changeset)
        placeholder = placeholder_or_empty(Media.get_random_placeholder() |> List.first())
        {:noreply, assign(socket, changeset: changeset, placeholder: placeholder)}
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

  def toggler(assigns) do
    ~H"""
    <div
      class="flex items-center justify-start"
      x-data="{ toggle: '1' }"
      x-init="() => { $watch('toggle', active => $dispatch('toggle-change', { toggle: active })) }"
      id="toggle-lit-ai"
      phx-hook="Toggle"
    >
      <div
        class="relative w-12 h-6 rounded-full transition duration-200 ease-linear"
        x-bind:class="[toggle === '1' ? 'bg-accent-main' : 'bg-dis-btn']"
      >
        <label
          for="toggle"
          class="absolute left-0 -top-10 w-6 h-6 mb-2 bg-white border-2 rounded-full cursor-pointer transition transform duration-100 ease-linear"
          x-bind:class="[toggle === '1' ? 'translate-x-full border-accent-main' : 'translate-x-0 border-dis-btn']"
        >
        </label>
        <input type="hidden" name="toggle" value="off" />
        <input
          type="checkbox"
          id="toggle"
          name="toggle"
          class="hidden"
          @click="toggle === '0' ? toggle = '1' : toggle = '0'"
        />
      </div>
    </div>
    """
  end

  def img(assigns) do
    assigns = assign_new(assigns, :img_url, fn -> nil end)
    assigns = assign_new(assigns, :aspect_ratio, fn -> nil end)
    assigns = assign_new(assigns, :request_id, fn -> nil end)
    assigns = assign_new(assigns, :request_completed, fn -> false end)

    assigns =
      assign_new(assigns, :spin, fn ->
        assigns.request_id != nil and assigns.request_completed == false
      end)

    if assigns.spin do
      ~H"""
      <div
        x-data={"{ showImage: false, imageUrl: '#{@img_url}' }"}
        class={"bg-sec flex items-center justify-center max-w-lg overflow-hidden rounded-lg aspect-#{@aspect_ratio} transition-all duration-300 mx-auto"}
      >
        <svg
          class="animate-slow-spin"
          xmlns="http://www.w3.org/2000/svg"
          width="14"
          height="14"
          fill="none"
        >
          <g clip-path="url(#a)">
            <g stroke="#fff" stroke-linecap="round" stroke-linejoin="round" clip-path="url(#b)">
              <path d="M7 1.167V3.5M7 10.5v2.333M2.876 2.876l1.65 1.65M9.473 9.473l1.651 1.651M1.167 7H3.5M10.5 7h2.333M2.876 11.124l1.65-1.65M9.473 4.527l1.651-1.651" />
            </g>
          </g>
          <defs>
            <clipPath id="a"><path fill="#fff" d="M0 0h14v14H0z" /></clipPath>
            <clipPath id="b"><path fill="#fff" d="M0 0h14v14H0z" /></clipPath>
          </defs>
        </svg>
      </div>
      """
    else
      ~H"""
      <div
        x-data={"{ showImage: false, imageUrl: '#{@img_url}' }"}
        class={"bg-sec max-w-lg overflow-hidden rounded-lg aspect-#{@aspect_ratio} transition-all duration-300 mx-auto"}
      >
        <img
          x-show="showImage"
          x-transition.duration.500ms
          x-bind:src="imageUrl"
          x-on:load="showImage = true"
          alt="Generated picture"
          class="w-full h-full object-cover aspect-cover"
        />
      </div>
      """
    end
  end

  def generate_btn(assigns) do
    assigns = assign_new(assigns, :request_id, fn -> nil end)
    assigns = assign_new(assigns, :request_completed, fn -> false end)

    assigns =
      assign_new(assigns, :spin, fn ->
        assigns.request_id != nil and assigns.request_completed == false
      end)

    ~H"""
    <div class="pb-7 pt-12 flex">
      <button
        type="submit"
        class="btn-small flex items-center justify-center gap-3 py-5 bg-accent-main rounded-full w-full"
        x-bind:disabled={"#{@spin} && true"}
      >
        <svg
          x-bind:class={"#{@spin} && 'animate-slow-spin'"}
          xmlns="http://www.w3.org/2000/svg"
          width="14"
          height="14"
          fill="none"
        >
          <g clip-path="url(#a)">
            <g stroke="#fff" stroke-linecap="round" stroke-linejoin="round" clip-path="url(#b)">
              <path d="M12.917 2.333v3.5h-3.5M.083 11.667v-3.5h3.5" /><path d="M1.547 5.25a5.25 5.25 0 0 1 8.663-1.96l2.707 2.543M.083 8.167 2.79 10.71a5.25 5.25 0 0 0 8.663-1.96" />
            </g>
          </g>
          <defs>
            <clipPath id="a"><path fill="#fff" d="M0 0h14v14H0z" /></clipPath>
            <clipPath id="b"><path fill="#fff" d="M-.5 0h14v14h-14z" /></clipPath>
          </defs>
        </svg>
        <span><%= gettext("Generate") %></span>
      </button>
    </div>
    """
  end

  def stage_nav(assigns) do
    ~H"""
    <div class="mt-3 flex text-xs sm:text-base">
      <%= for stage <- stages() do %>
        <%= if stage.id <= assigns.stage do %>
          <%= if stage.id == assigns.stage do %>
            <div class="cursor-pointer capitalize text-zinc-100 font-light">
              <%= stage.name %>
            </div>
          <% else %>
            <div
              phx-click={
                JS.push("set_stage") |> JS.transition("opacity-0 translate-y-6", to: "#stage-box")
              }
              phx-value-stage={stage.id}
              class="cursor-pointer capitalize text-zinc-400 hover:text-zinc-100 font-light"
            >
              <%= stage.name %>
            </div>
          <% end %>
          <span class="last:hidden pb-1 mx-2 text-zinc-400">></span>
        <% end %>
      <% end %>
    </div>
    """
  end

  def img_box(assigns) do
    assigns = assign_new(assigns, :prompt_id, fn -> nil end)
    assigns = assign_new(assigns, :value, fn -> nil end)
    assigns = assign_new(assigns, :stage_id, fn -> nil end)

    if assigns.value == nil do
      ~H"""
      <div></div>
      """
    else
      src = default_img_or(assigns.src)

      label = assigns.label |> String.upcase()
      url = insert_tr(src, label)
      assigns = assign(assigns, :url, url)

      ~H"""
      <div
        id={"#{@url}"}
        class="mr-8 aspect-cover overflow-hidden rounded-xl border-2 border-stroke-main hover:border-accent-main transition inline-block min-w-[250px] sm:min-w-fit sm:mr-0"
        x-bind:class={"'#{@value}' == '#{@prompt_id}' && 'border-accent-main'"}
        x-data={"{ showImage: false, imageUrl: '#{@url}' }"}
      >
        <img
          x-show="showImage"
          x-transition.duration.500ms
          x-bind:src="imageUrl"
          x-on:load="showImage = true"
          alt={assigns.label}
          class="w-full h-full object-cover aspect-cover cursor-pointer transition duration-300 ease-out hover:scale-[1.02] hover:saturate-[1.3]"
          phx-click={next_stage_push_anim(@stage_id)}
          phx-value-value={assigns.value}
        />
      </div>
      """
    end
  end

  defp next_stage_push_anim(stage_id) do
    if stage_id >= 3 do
      JS.push("next")
    else
      JS.push("next") |> JS.transition("opacity-0 translate-y-6", to: "#stage-box")
    end
  end

  defp default_img_or(img) do
    if img == nil do
      "https://ik.imagekit.io/soulgenesis/litnet/realm_fantasy.jpg"
    else
      img
    end
  end

  def gender_picker(assigns) do
    ~H"""
    <div class="px-8 mt-5 mb-4 flex w-full gap-5">
      <button
        x-bind:class={"'#{assigns.gender}' == 'female' ? 'underline text-pink-600': ''"}
        class="capitalize link"
        phx-click="change_gender"
        phx-value-gender={:female}
      >
        <%= gettext("Female") %>
      </button>
      <!-- <button class="capitalize link text-xl" phx-click="change_gender" phx-value-gender={:couple}> -->
      <!--   Пара -->
      <!-- </button> -->
      <button
        x-bind:class={"'#{assigns.gender}' == 'male' ? 'underline text-pink-600': ''"}
        class="capitalize link"
        phx-click="change_gender"
        phx-value-gender={:male}
      >
        <%= gettext("Male") %>
      </button>
    </div>
    """
  end

  def stage_box(assigns) do
    ~H"""
    <div class="min-h-[400px] sm:min-h-full  flex flex-nowrap sm:gap-5 overflow-x-scroll sm:overflow-x-hidden hide-scroll-bar sm:grid sm:grid-cols-3">
      <%= render_slot(@inner_block) %>
    </div>
    """
  end

  def stage_msg(assigns) do
    ~H"""
    <div class="mt-5 mb-4">
      <h1 class="text-base font-light">
        <%= assigns.msg %>
      </h1>
    </div>
    """
  end

  defp stages do
    [
      %{
        id: 0,
        name: gettext("Cover type"),
        msg: gettext("What type of cover is more suitable for your book?")
      },
      %{id: 1, name: gettext("World"), msg: gettext("What world is your book set in?")},
      %{id: 2, name: gettext("Vibe"), msg: gettext("What vibe does your book have?")},
      %{id: 3, name: gettext("Style"), msg: gettext("What style do you prefer?")},
      %{id: 4, name: nil, msg: nil}
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
