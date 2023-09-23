defmodule ChiyaWeb.TagController do
  use ChiyaWeb, :controller
  alias Chiya.Tags

  def index(conn, _params) do
    tags = Chiya.Tags.list_admin_tags()

    render(conn, :index, tags: tags)
  end

  def show(conn, %{"id" => id}) do
    tag = Tags.get_tag!(id)
    render(conn, :show, tag: tag)
  end

  def apply_prepare(conn, %{"id" => id}) do
    tag = Tags.get_tag!(id)

    notes =
      tag
      |> Chiya.Notes.list_apply_notes()
      |> Enum.filter(fn note ->
        exists =
          note.tags
          |> Enum.map(fn t -> t.name end)
          |> Enum.member?(tag.name)

        !exists
      end)

    render(conn, :apply_prepare, tag: tag, notes: notes)
  end

  def apply_run(conn, %{"id" => id}) do
    tag = Tags.get_tag!(id)
    notes = Chiya.Notes.list_apply_notes(tag)

    Enum.each(notes, fn note ->
      Chiya.Tags.TagUpdater.add_tags(note, [tag.slug])
    end)

    notes = Chiya.Notes.list_apply_notes(tag)
    render(conn, :apply_prepare, tag: tag, notes: notes)
  end

  def edit(conn, %{"id" => id}) do
    tag = Tags.get_tag!(id)
    changeset = Tags.change_tag(tag)

    render(conn, :edit,
      tag: tag,
      changeset: changeset,
      page_title: "EDIT #{tag.name}"
    )
  end

  def update(conn, %{"id" => id, "tag" => tag_params}) do
    tag = Tags.get_tag!(id)

    case Tags.update_tag(tag, tag_params) do
      {:ok, _tag} ->
        conn
        |> put_flash(:info, "Tags updated successfully.")
        |> redirect(to: ~p"/admin/tags")

      {:error, %Ecto.Changeset{} = changeset} ->
        render(conn, :edit,
          tag: tag,
          changeset: changeset,
          page_title: "EDIT #{tag.name}"
        )
    end
  end
end
