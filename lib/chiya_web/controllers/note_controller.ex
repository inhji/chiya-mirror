defmodule ChiyaWeb.NoteController do
  use ChiyaWeb, :controller
  import Plug.Conn, only: [assign: 3]

  alias Chiya.Notes
  alias Chiya.Notes.{Note, NoteImport}

  def new(conn, _params) do
    default_channels = get_default_channels(conn)

    changeset =
      %Note{}
      |> Notes.preload_note()
      |> Notes.change_note()

    render(conn, :new,
      changeset: changeset,
      channels: to_channel_options(),
      selected_channels: default_channels,
      tags: [],
      page_title: "New Note"
    )
  end

  def create(conn, %{"note" => note_params}) do
    note_params = from_channel_ids(note_params)

    case Notes.create_note(note_params) do
      {:ok, note} ->
        conn
        |> put_flash(:info, "Note created successfully.")
        |> redirect(to: ~p"/admin/notes/#{note}")

      {:error, %Ecto.Changeset{} = changeset} ->
        render(conn, :new,
          changeset: changeset,
          channels: to_channel_options(),
          selected_channels: nil,
          tags: [],
          page_title: "New Note"
        )
    end
  end

  def edit(conn, %{"id" => id}) do
    note = Notes.get_note_preloaded!(id)
    changeset = Notes.change_note(note)
    selected_channels = Enum.map(note.channels, fn c -> c.id end)

    render(conn, :edit,
      note: note,
      changeset: changeset,
      channels: to_channel_options(),
      selected_channels: selected_channels,
      tags: note.tags,
      page_title: "EDIT #{note.name}"
    )
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
        render(conn, :edit,
          note: note,
          changeset: changeset,
          channels: to_channel_options(),
          selected_channels: nil,
          tags: note.tags,
          page_title: "EDIT #{note.name}"
        )
    end
  end

  def delete(conn, %{"id" => id}) do
    note = Notes.get_note!(id)
    {:ok, _note} = Notes.delete_note(note)

    conn
    |> put_flash(:info, "Note deleted successfully.")
    |> redirect(to: ~p"/admin/notes")
  end

  def raw(conn, %{"id" => id}) do
    raw_note =
      id
      |> Notes.get_note!()
      |> Notes.preload_note()
      |> ChiyaWeb.Exim.export_note()

    conn
    |> text(raw_note)
  end

  def publish(conn, %{"id" => id}) do
    note = Notes.get_note_preloaded!(id)

    case Notes.publish_note(note, NaiveDateTime.local_now()) do
      {:ok, note} ->
        conn
        |> put_flash(:info, "Note published successfully.")
        |> redirect(to: ~p"/admin/notes/#{note}")
    end
  end

  def unpublish(conn, %{"id" => id}) do
    note = Notes.get_note_preloaded!(id)

    case Notes.publish_note(note, nil) do
      {:ok, note} ->
        conn
        |> put_flash(:info, "Note un-published successfully.")
        |> redirect(to: ~p"/admin/notes/#{note}")
    end
  end

  def edit_image(conn, %{"image_id" => id}) do
    image = Notes.get_note_image!(id)
    changeset = Notes.change_note_image(image)
    render(conn, :edit_image, image: image, changeset: changeset)
  end

  def update_image(conn, %{"image_id" => id, "note_image" => image_params}) do
    image = Notes.get_note_image!(id)

    case Notes.update_note_image(image, image_params) do
      {:ok, image} ->
        conn
        |> put_flash(:info, "Image updated successfully.")
        |> redirect(to: ~p"/admin/notes/#{image.note_id}")

      {:error, %Ecto.Changeset{} = changeset} ->
        render(conn, :edit_image, image: image, changeset: changeset)
    end
  end

  def import_prepare(conn, _params) do
    render(conn, :import,
      changeset: NoteImport.change_note_import(%{}),
      page_title: "Import Note"
    )
  end

  def import_run(conn, %{
        "note_import" => %{
          "file" => %{
            path: path,
            content_type: "text/markdown",
            filename: filename
          }
        }
      }) do
    case File.read(path) do
      {:ok, content} ->
        note_params = %{
          name: filename,
          content: content
        }

        case Notes.create_note(note_params) do
          {:ok, note} ->
            conn
            |> put_flash(:info, "Note created successfully.")
            |> redirect(to: ~p"/admin/notes/#{note}")

          {:error, %Ecto.Changeset{} = changeset} ->
            render(conn, :new, changeset: changeset, channels: to_channel_options())
        end

      _ ->
        render(conn, :import,
          changeset: NoteImport.change_note_import(%{}),
          page_title: "Import Note"
        )
    end
  end

  def import_run(conn, _params) do
    conn
    |> put_flash(:error, "Error while importing.")
    |> render(:import,
      changeset: NoteImport.change_note_import(%{}),
      page_title: "Import Note"
    )
  end

  defp get_default_channels(%Plug.Conn{} = conn) do
    if conn.assigns.settings.default_channel do
      [conn.assigns.settings.default_channel.id]
    else
      []
    end
  end

  defp from_channel_ids(note_params) do
    selected_ids = Enum.map(note_params["channels"] || [], &String.to_integer/1)

    selected_channels =
      Chiya.Channels.list_channels()
      |> Enum.filter(fn c -> Enum.member?(selected_ids, c.id) end)

    Map.put(note_params, "channels", selected_channels)
  end

  defp to_channel_options(items \\ nil),
    do:
      Enum.map(items || Chiya.Channels.list_channels(), fn c ->
        {Chiya.Channels.Channel.icon(c) <> " " <> c.name, c.id}
      end)
end
