defmodule ChiyaWeb.CommentController do
  use ChiyaWeb, :controller

  def index(conn, _params) do
    comments = Chiya.Notes.list_note_comments()
    render(conn, comments: comments)
  end

  def show(conn, %{"id" => comment_id}) do
    comment = Chiya.Notes.get_note_comment!(comment_id)
    render(conn, comment: comment)
  end

  def create(conn, %{"slug" => note_slug, "note_comment" => comment_params}) do
    _note = Chiya.Notes.get_note_by_slug_preloaded!(note_slug)

    case Chiya.Notes.create_note_comment(comment_params) do
      {:ok, _comment} ->
        redirect(conn, to: ~p"/note/#{note_slug}?error=0")

      {:error, _changeset} ->
        redirect(conn, to: ~p"/note/#{note_slug}?error=1")
    end
  end
end
