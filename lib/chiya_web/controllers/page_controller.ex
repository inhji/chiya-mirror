defmodule ChiyaWeb.PageController do
  use ChiyaWeb, :controller

  def home(conn, _params) do
    settings = conn.assigns.settings

    channel =
      case settings.home_channel_id do
        nil -> nil
        id -> Chiya.Channels.get_channel!(id) |> Chiya.Channels.preload_channel_public()
      end

    render(conn, :home,
      layout: {ChiyaWeb.Layouts, "public.html"},
      channel: channel,
      page_title: "Home"
    )
  end

  def channel(conn, %{"slug" => channel_slug}) do
    channel =
      Chiya.Channels.get_channel_by_slug!(channel_slug)
      |> Chiya.Channels.preload_channel_public()

    render(conn, :channel,
      layout: {ChiyaWeb.Layouts, "public.html"},
      channel: channel,
      page_title: channel.name
    )
  end

  def tag(conn, %{"slug" => tag_slug}) do
    tag = Chiya.Tags.get_tag_by_slug!(tag_slug)

    render(conn, :tag,
      layout: {ChiyaWeb.Layouts, "public.html"},
      tag: tag,
      page_title: tag.name
    )
  end

  def note(conn, %{"slug" => note_slug}) do
    note = Chiya.Notes.get_note_by_slug_preloaded!(note_slug)
    changeset = Chiya.Notes.change_note_comment(%Chiya.Notes.NoteComment{}, %{note_id: note.id})

    if is_nil(note.published_at) and is_nil(conn.assigns.current_user) do
      render_error(conn, :not_found)
    else
      render(conn, :note,
        layout: {ChiyaWeb.Layouts, "public.html"},
        note: note,
        page_title: note.name,
        changeset: changeset
      )
    end
  end

  ### ========= REDIRECTS

  def about(conn, _params) do
    redirect(conn, to: ~p"/note/about")
  end

end
