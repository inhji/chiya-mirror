defmodule ChiyaWeb.PageController do
  use ChiyaWeb, :controller

  plug :put_layout, html: {ChiyaWeb.Layouts, :public}

  def home(conn, _params) do
    settings = conn.assigns.settings

    channel =
      case settings.home_channel_id do
        nil -> nil
        id -> Chiya.Channels.get_channel!(id) |> Chiya.Channels.preload_channel_public()
      end

    render(conn, :home,
      channel: channel,
      page_title: "Home"
    )
  end

  def channel(conn, %{"slug" => channel_slug}) do
    channel =
      Chiya.Channels.get_channel_by_slug!(channel_slug)
      |> Chiya.Channels.preload_channel_public()

    render(conn, :channel,
      channel: channel,
      page_title: channel.name
    )
  end

  def tag(conn, %{"slug" => tag_slug}) do
    tag = Chiya.Tags.get_tag_by_slug!(tag_slug)

    render(conn, :tag,
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
        note: note,
        page_title: note.name,
        changeset: changeset
      )
    end
  end

  def about(conn, _params) do
    note = Chiya.Notes.get_note_by_slug_preloaded("about")
    user = Chiya.Accounts.get_user!(1)

    render(conn, :about,
      note: note,
      user: user,
      page_title: "About"
    )
  end

  def wiki(conn, _params) do
    [channel, notes_updated, notes_published] =
      case conn.assigns.settings.wiki_channel_id do
        nil ->
          [nil, nil, nil]

        id ->
          channel = Chiya.Channels.get_channel!(id)
          updated = Chiya.Notes.list_notes_by_channel_updated(channel, 5)
          published = Chiya.Notes.list_notes_by_channel_published(channel, 5)
          [channel, updated, published]
      end

    render(conn, :wiki,
      channel: channel,
      notes_updated: notes_updated,
      notes_published: notes_published,
      page_title: "Wiki"
    )
  end

  def bookmarks(conn, _params) do
    [channel, notes] =
      case conn.assigns.settings.bookmark_channel_id do
        nil ->
          [nil, nil]

        id ->
          channel = Chiya.Channels.get_channel!(id)
          notes = Chiya.Notes.list_notes_by_channel_updated(channel, 999)
          [channel, notes]
      end

    render(conn, :bookmarks,
      channel: channel,
      notes: notes,
      page_title: "Bookmarks"
    )
  end
end
