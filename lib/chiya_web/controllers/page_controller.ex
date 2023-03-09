defmodule ChiyaWeb.PageController do
  use ChiyaWeb, :controller

  def home(conn, _params) do
    # The home page is often custom made,
    # so skip the default app layout.
    render(conn, :home, layout: {ChiyaWeb.Layouts, "public.html"})
  end

  def channel(conn, %{"slug" => channel_slug}) do
    channel = Chiya.Channels.get_channel_by_slug_preloaded!(channel_slug)
    render(conn, :channel, layout: {ChiyaWeb.Layouts, "public.html"}, channel: channel)
  end
end
