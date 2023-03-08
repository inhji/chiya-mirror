defmodule ChiyaWeb.PageController do
  use ChiyaWeb, :controller

  def home(conn, _params) do
    # The home page is often custom made,
    # so skip the default app layout.
    settings = Chiya.Site.get_settings()
    render(conn, :home, layout: false, settings: settings)
  end
end
