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
        <.h2>Настроения</.h2>
        <.p><%= assigns.request.vibe %></.p>
      </div>
      <div>
        <.h2>Описание</.h2>
        <.p><%= assigns.request.description %></.p>
      </div>
    </div>
    """
  end

  def request_status(assigns) do
    ~H"""
    <%= if assigns.completed do %>
      <div class="p-2 absolute top-4 left-4 rounded-full bg-teal-200">
        <svg class="fill-teal-700" xmlns="http://www.w3.org/2000/svg" viewBox="0 0 24 24" width="24" height="24"><path fill="none" d="M0 0h24v24H0z"/><path d="M10 15.172l9.192-9.193 1.415 1.414L10 18l-6.364-6.364 1.414-1.414z"/></svg>
      </div>
    <% else %>
      <div class="p-2 absolute top-4 left-4 rounded-full bg-orange-200">
        <svg class="fill-orange-600 animate-slow-spin" xmlns="http://www.w3.org/2000/svg" viewBox="0 0 24 24" width="24" height="24"><path fill="none" d="M0 0h24v24H0z"/><path d="M3.055 13H5.07a7.002 7.002 0 0 0 13.858 0h2.016a9.001 9.001 0 0 1-17.89 0zm0-2a9.001 9.001 0 0 1 17.89 0H18.93a7.002 7.002 0 0 0-13.858 0H3.055z"/></svg>
      </div>
    <% end %>
    """
  end

  def button(assigns) do
    ~H"""
    <button class="px-3 py-2 md:px-5 md:py-3 text-sm md:text-base text-slate-200 hover:text-slate-300 rounded-full hover:scale-105 bg-gradient-to-r from-pink-800 to-pink-500 border-2 border-pink-600 hover:border-gray-200 transition-all duration-200">
      <%= render_slot(@inner_block) %>
    </button>
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
    ~H"""
    <p class="lg:text-lg font-light text-gray-400">
      <%= render_slot(@inner_block) %>
    </p>
    """
  end
end