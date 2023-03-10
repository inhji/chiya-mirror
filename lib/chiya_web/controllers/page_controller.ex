defmodule ChiyaWeb.PageController do
  use ChiyaWeb, :controller

  def home(conn, _params) do
    # The home page is often custom made,
    # so skip the default app layout.
    settings = conn.assigns.settings

    channel =
      if settings.home_channel_id != nil do
        IO.inspect(settings)
        Chiya.Channels.get_channel_preloaded!(settings.home_channel_id)
      else
        nil
      end

    render(conn, :home, layout: {ChiyaWeb.Layouts, "public.html"}, channel: channel)
  end

  def channel(conn, %{"slug" => channel_slug}) do
    channel = Chiya.Channels.get_channel_by_slug_preloaded!(channel_slug)
    render(conn, :channel, layout: {ChiyaWeb.Layouts, "public.html"}, channel: channel)
  end

  def note(conn, %{"slug" => note_slug}) do
    note = Chiya.Notes.get_note_by_slug_preloaded!(note_slug)
    render(conn, :note, layout: {ChiyaWeb.Layouts, "public.html"}, note: note)
  end
end
