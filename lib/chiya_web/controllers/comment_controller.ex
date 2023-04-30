defmodule ChiyaWeb.CommentController do
  use ChiyaWeb, :controller

  def create(conn, %{"slug" => note_slug, "note_comment" => comment_params}) do
    note = Chiya.Notes.get_note_by_slug_preloaded!(note_slug)

    IO.inspect(comment_params)

    case Chiya.Notes.create_note_comment(comment_params) do
      {:ok, _comment} ->
        redirect(conn, to: ~p"/#{note_slug}?error=0")

      {:error, changeset} ->
        redirect(conn, to: ~p"/#{note_slug}?error=1")
    end
  end
end
