defmodule ChiyaWeb.PageController do
  use ChiyaWeb, :controller

  def home(conn, _params) do
    # The home page is often custom made,
    # so skip the default app layout.
    settings = Chiya.Site.get_settings()
    render(conn, :home, layout: false, settings: settings)
  end

  def channel(conn, %{"slug" => channel_slug}) do
    channel = Chiya.Channels.get_channel_by_slug_preloaded!(channel_slug)
    render(conn, :channel, layout: false, channel: channel)
  end
end
