defmodule LitcoversWeb.UiComponents do
  use Phoenix.Component

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
