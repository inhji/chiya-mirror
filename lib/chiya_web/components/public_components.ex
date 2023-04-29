defmodule ChiyaWeb.PublicComponents do
  use Phoenix.Component

  use Phoenix.VerifiedRoutes,
    endpoint: ChiyaWeb.Endpoint,
    router: ChiyaWeb.Router,
    statics: ChiyaWeb.static_paths()

  @doc """
  Renders a horizontal line
  """
  def line(assigns) do
    ~H"""
    <hr class="my-6 border-theme-base/20" />
    """
  end

  @doc """
  Renders a header with title.
  """
  attr :class, :string, default: nil
  attr :inline, :boolean, default: false

  slot :inner_block, required: true
  slot :subtitle
  slot :actions

  def header(assigns) do
    ~H"""
    <header class={[@actions != [] && "flex items-center justify-between gap-6", @class]}>
      <div>
        <h1 class="text-lg font-semibold leading-8 text-gray-800 dark:text-gray-200">
          <%= render_slot(@inner_block) %>
          <span :if={@inline} class="text-sm leading-6 font-normal text-gray-600 dark:text-gray-400">
            <%= render_slot(@subtitle) %>
          </span>
        </h1>
        <p
          :if={@subtitle != [] && @inline == false}
          class="mt-2 text-sm leading-6 text-gray-600 dark:text-gray-400"
        >
          <%= render_slot(@subtitle) %>
        </p>
      </div>
      <div class="flex-none"><%= render_slot(@actions) %></div>
    </header>
    """
  end
end
