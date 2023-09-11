defmodule ChiyaWeb.TagController do
  use ChiyaWeb, :controller
  alias Chiya.Tags

  def index(conn, params) do
    tags = Chiya.Tags.list_admin_tags(params)

    render(conn, :index, tags: tags)
  end

  def show(conn, %{"id" => id}) do
    tag = Tags.get_tag!(id)
    render(conn, :show, tag: tag)
  end

  def apply(conn, %{"id" => id}) do
    tag = Tags.get_tag!(id)
    notes = Chiya.Notes.list_apply_notes(tag.regex)

    render(conn, :apply_prepare, tag: tag, notes: notes)
  end

  def edit(conn, %{"id" => id}) do
    IO.inspect(id)
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

      # TODO: set channels from changeset when error happened?

      {:error, %Ecto.Changeset{} = changeset} ->
        render(conn, :edit,
          tag: tag,
          changeset: changeset,
          page_title: "EDIT #{tag.name}"
        )
    end
  end
end