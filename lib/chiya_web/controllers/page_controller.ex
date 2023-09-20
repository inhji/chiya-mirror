defmodule ChiyaWeb.PageController do
  use ChiyaWeb, :controller
  alias Chiya.Channels

  plug :put_layout, html: {ChiyaWeb.Layouts, :public}
  plug :put_assigns

  def home(conn, params) do
    if id = conn.assigns.settings.home_channel_id do
      channel = Channels.get_channel!(id)
      {:ok, {notes, meta}} = Chiya.Notes.list_home_notes(channel, params)

      render(conn, :home,
        channel: channel,
        notes: notes,
        meta: meta,
        page_title: "Home",
        page_header: false
      )
    else
      not_found(conn)
    end
  end

  def channel(conn, %{"slug" => channel_slug}) do
    channel =
      channel_slug
      |> Channels.get_channel_by_slug!()
      |> Channels.preload_channel_public()

    render(conn, :channel,
      channel: channel,
      page_title: channel.name,
      content: channel.content
    )
  end

  def tag(conn, %{"slug" => tag_slug}) do
    tag = Chiya.Tags.get_tag_by_slug!(tag_slug)

    render(conn, :tag,
      tag: tag,
      page_title: "Tagged with #{tag.name}"
    )
  end

  def note(conn, %{"slug" => note_slug}) do
    note = Chiya.Notes.get_note_by_slug_preloaded!(note_slug)
    changeset = Chiya.Notes.change_note_comment(%Chiya.Notes.NoteComment{}, %{note_id: note.id})

    if note.published_at || conn.assigns.current_user do
      render(conn, :note,
        note: note,
        changeset: changeset,
        page_title: note.name,
        page_header: false
      )
    else
      not_found(conn)
    end
  end

  def about(conn, _params) do
    note = Chiya.Notes.get_note_by_slug_preloaded("about")
    user = Chiya.Accounts.get_user!(1)

    if note && user do
      render(conn, :about,
        note: note,
        user: user,
        page_title: user.name
      )
    else
      not_found(conn)
    end
  end

  def wiki(conn, _params) do
    if id = conn.assigns.settings.wiki_channel_id do
      channel = Chiya.Channels.get_channel!(id)
      notes = Chiya.Notes.list_notes_by_channel_updated(channel, 999)

      render(conn, :wiki,
        channel: channel,
        notes: notes,
        page_title: channel.name,
        content: channel.content
      )
    else
      not_found(conn)
    end
  end

  def bookmarks(conn, _params) do
    if id = conn.assigns.settings.bookmark_channel_id do
      channel = Chiya.Channels.get_channel!(id)
      notes = Chiya.Notes.list_notes_by_channel_published(channel, 999)

      render(conn, :bookmarks,
        channel: channel,
        notes: notes,
        page_title: "#{Enum.count(notes)} Bookmarks"
      )
    else
      not_found(conn)
    end
  end

  defp not_found(conn) do
    conn
    |> assign(:page_title, "404 Not found")
    |> render_error(:not_found)
  end

  defp put_assigns(conn, opts) do
    conn
    |> assign(:page_header, true)
  end
end
