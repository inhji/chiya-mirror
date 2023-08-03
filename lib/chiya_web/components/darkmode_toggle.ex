defmodule ChiyaWeb.DarkModeToggle do
  use Phoenix.Component

  attr :class, :string, default: ""

  def darkmode_toggle(assigns) do
    ~H"""
    <.link href="#" id="dark-mode-toggle" class={["text-sm leading-6", @class]}>
      <span class="hidden dark:inline">🌙</span>
      <span class="inline dark:hidden">☀️</span>
    </.link>
    """
  end
end
