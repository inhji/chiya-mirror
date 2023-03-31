defmodule ChiyaWeb.ApiController do
  use ChiyaWeb, :controller

  def notes(conn, _params) do
    notes = Chiya.Notes.list_notes()
    json(conn, %{notes: notes})
  end
end
