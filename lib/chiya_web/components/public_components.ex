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
    <hr class="my-6 border-theme-dim" />
    """
  end
end
