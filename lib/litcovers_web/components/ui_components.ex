defmodule LitcoversWeb.UiComponents do
  use Phoenix.Component

  def request_info(assigns) do
    ~H"""
    <div class="mt-5 flex flex-col gap-7">
      <div>
        <.h2>Автор</.h2>
        <.p><%= assigns.request.author %></.p>
      </div>
      <div>
        <.h2>Название</.h2>
        <.p><%= assigns.request.title %></.p>
      </div>
      <div>
        <.h2>Описание</.h2>
        <.p><%= assigns.request.description %></.p>
      </div>
      <div>
        <.h2>Final prompt</.h2>
        <.p><%= assigns.request.final_prompt %></.p>
      </div>
    </div>
    """
  end

  def pinger(assigns) do
    ~H"""
    <span class="absolute -top-1 -right-1 flex h-3 w-3">
      <span class="animate-ping absolute inline-flex h-full w-full rounded-full bg-sky-400 opacity-75"></span>
      <span class={"relative inline-flex rounded-full h-3 w-3 #{assigns.color}"}></span>
    </span>
    """
  end

  def cover_selector_box(assigns) do
    ~H"""
    <%= if assigns.selected_cover == nil do %>
      <div phx-click="select_cover" phx-value-cover_id={assigns.cover.id} class="aspect-cover cursor-pointer rounded overflow-hidden border-2 border-zinc-400 hover:border-pink-600">
        <img class="w-full h-full object-cover" src={insert_image_watermark(assigns.cover.cover_url)} />
      </div>
    <% else %>
      <%= if assigns.cover.id == assigns.selected_cover do %>
        <div class="aspect-cover rounded border-2 overflow-hidden border-lime-300">
          <img class="w-full h-full object-cover" src={assigns.cover.cover_url} />
        </div>
      <% else %>
        <div class="aspect-cover rounded border-2 brightness-50 overflow-hidden border-zinc-400">
          <img class="w-full h-full object-cover" src={insert_image_watermark(assigns.cover.cover_url)} />
        </div>
      <% end %>
    <% end %>
    """
  end

  def cover_status_box(assigns) do
    ~H"""
    <%= if assigns.request.completed do %>
      <div class="relative flex items-center justify-center aspect-cover w-full border-2 bg-zinc-800 hover:bg-zinc-900 rounded border-zinc-400 hover:border-pink-500 transition duration-300">
        <.request_status completed={assigns.request.completed} />
        <div class="space-y-2">
          <.p class="text-center font-extrabold group-hover:text-zinc-50"><%= assigns.request.title %></.p>
          <.p class="text-center text-teal-400 group-hover:text-zinc-50">Обложки готовы</.p>
        </div>
      </div>
    <% else %>
      <div class="p-4 relative flex items-center group justify-center aspect-cover w-full border-2 bg-zinc-800 hover:bg-zinc-900 rounded border-zinc-400 hover:border-pink-500 transition duration-300">
        <.request_status completed={assigns.request.completed} />
        <div class="space-y-2">
          <.p class="text-center font-extrabold group-hover:text-zinc-50"><%= assigns.request.title %></.p>
          <.p class="text-center text-orange-400 group-hover:text-zinc-50">Обложки готовятся</.p>
        </div>
      </div>
    <% end %>
    """
  end

  def cover_box(assigns) do
    ~H"""
    <div class="aspect-cover border-2 border-zinc-400 hover:border-pink-600 transition duration-300 rounded overflow-hidden">
      <img class="w-full h-full object-cover" src={assigns.src} />
    </div>
    """
  end

  def request_status(assigns) do
    ~H"""
    <%= if assigns.completed do %>
      <div class="p-2 absolute top-4 right-4 rounded-full bg-cyan-200">
        <svg class="fill-cyan-700" xmlns="http://www.w3.org/2000/svg" viewBox="0 0 24 24" width="24" height="24"><path fill="none" d="M0 0h24v24H0z"/><path d="M10 15.172l9.192-9.193 1.415 1.414L10 18l-6.364-6.364 1.414-1.414z"/></svg>
      </div>
    <% else %>
      <div class="p-2 absolute top-4 right-4 rounded-full bg-orange-200">
        <svg class="fill-orange-600 animate-slow-spin" xmlns="http://www.w3.org/2000/svg" viewBox="0 0 24 24" width="24" height="24"><path fill="none" d="M0 0h24v24H0z"/><path d="M3.055 13H5.07a7.002 7.002 0 0 0 13.858 0h2.016a9.001 9.001 0 0 1-17.89 0zm0-2a9.001 9.001 0 0 1 17.89 0H18.93a7.002 7.002 0 0 0-13.858 0H3.055z"/></svg>
      </div>
    <% end %>
    """
  end

  def insert_image_watermark(link) do
    uri = link |> URI.parse()
    %URI{host: host, path: path} = uri

    {filename, list} = path |> String.split("/") |> List.pop_at(-1)
    bucket = list |> List.last()
    transformation = "tr:ot-LITCOVERS,otc-FFFFFF55,ots-45"

    case host do
      "ik.imagekit.io" ->
        Path.join(["https://", host, bucket, transformation, filename])

      _ ->
        link
    end
  end

  def button(assigns) do
    ~H"""
    <button class="px-3 py-2 md:px-5 md:py-3 text-sm md:text-base text-slate-200 hover:text-slate-300 rounded-full hover:scale-105 bg-gradient-to-r from-pink-800 to-pink-500 border-2 border-pink-600 hover:border-gray-200 transition-all duration-200">
      <%= render_slot(@inner_block) %>
    </button>
    """
  end

  def download_btn(assigns) do
    ~H"""
    <a href={"data:image/png;base64,#{assigns.src}"} download="cover.png" class="px-3 py-2 md:px-5 md:py-3 text-sm md:text-base text-slate-200 hover:text-slate-300 rounded-full hover:scale-105 bg-pink-500 border-2 border-pink-600 hover:border-gray-200 transition-all duration-200">
      <%= render_slot(@inner_block) %>
    </a>
    """
  end

  def h1(assigns) do
    ~H"""
    <h1 class="text-2xl lg:text-4xl font-bold text-gray-200">
      <%= render_slot(@inner_block) %>
    </h1>
    """
  end

  def h2(assigns) do
    ~H"""
    <h2 class="text-xl lg:text-2xl font-bold text-gray-200">
      <%= render_slot(@inner_block) %>
    </h2>
    """
  end

  def p(assigns) do
    assigns = assign_new(assigns, :class, fn -> nil end)
    ~H"""
    <p class={"lg:text-lg font-light text-gray-400 #{assigns.class}"}>
      <%= render_slot(@inner_block) %>
    </p>
    """
  end
end
