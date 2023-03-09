defmodule ChiyaWeb.NoteController do
  use ChiyaWeb, :controller

  alias Chiya.Notes
  alias Chiya.Notes.Note

  def index(conn, _params) do
    notes = Notes.list_notes()
    render(conn, :index, notes: notes)
  end

  def new(conn, _params) do
    changeset = Notes.change_note(%Note{})
    render(conn, :new, changeset: changeset, channels: to_channel_options())
  end

  def create(conn, %{"note" => note_params}) do
    note_params = from_channel_ids(note_params)

    case Notes.create_note(note_params) do
      {:ok, note} ->
        conn
        |> put_flash(:info, "Note created successfully.")
        |> redirect(to: ~p"/admin/notes/#{note}")

      {:error, %Ecto.Changeset{} = changeset} ->
        render(conn, :new, changeset: changeset, channels: to_channel_options())
    end
  end

  def show(conn, %{"id" => id}) do
    # note = Notes.get_note!(id)
    # render(conn, :show, note: note)
    live_render(conn, NoteShowLive, session: %{"note_id" => id})
  end

  def edit(conn, %{"id" => id}) do
    note = Notes.get_note_preloaded!(id)
    changeset = Notes.change_note(note)
    render(conn, :edit, note: note, changeset: changeset, channels: to_channel_options())
  end

  def update(conn, %{"id" => id, "note" => note_params}) do
    note_params = from_channel_ids(note_params)
    note = Notes.get_note_preloaded!(id)

    case Notes.update_note(note, note_params) do
      {:ok, note} ->
        conn
        |> put_flash(:info, "Note updated successfully.")
        |> redirect(to: ~p"/admin/notes/#{note}")

      {:error, %Ecto.Changeset{} = changeset} ->
        render(conn, :edit, note: note, changeset: changeset, channels: to_channel_options())
    end
  end

  def delete(conn, %{"id" => id}) do
    note = Notes.get_note!(id)
    {:ok, _note} = Notes.delete_note(note)

    conn
    |> put_flash(:info, "Note deleted successfully.")
    |> redirect(to: ~p"/admin/notes")
  end

  defp from_channel_ids(note_params) do
    selected_ids = Enum.map(note_params["channels"] || [], &String.to_integer/1)

    selected_channels =
      Chiya.Channels.list_channels()
      |> Enum.filter(fn c -> Enum.member?(selected_ids, c.id) end)

    Map.put(note_params, "channels", selected_channels)
  end

  defp to_channel_options(items \\ nil),
    do: Enum.map(items || Chiya.Channels.list_channels(), fn c -> {c.name, c.id} end)
end
