defmodule ChiyaWeb.PageController do
  use ChiyaWeb, :controller

  def home(conn, _params) do
    # The home page is often custom made,
    # so skip the default app layout.
    settings = conn.assigns.settings

    channel =
      if settings.home_channel_id != nil do
        Chiya.Channels.get_channel_preloaded!(settings.home_channel_id)
        |> Chiya.Channels.preload_channel_public()
      else
        nil
      end

    render(conn, :home, layout: {ChiyaWeb.Layouts, "public.html"}, channel: channel)
  end

  def channel(conn, %{"slug" => channel_slug}) do
    channel =
      Chiya.Channels.get_channel_by_slug!(channel_slug)
      |> Chiya.Channels.preload_channel_public()

    render(conn, :channel, layout: {ChiyaWeb.Layouts, "public.html"}, channel: channel)
  end

  def note(conn, %{"slug" => note_slug}) do
    note = Chiya.Notes.get_note_by_slug_preloaded!(note_slug)

    if is_nil(note.published_at) do
      render_error(conn, :not_found)
    else 
      render(conn, :note, layout: {ChiyaWeb.Layouts, "public.html"}, note: note)
    end
  end
end
