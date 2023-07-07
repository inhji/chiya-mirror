defmodule ChiyaWeb.Error do
  import Plug.Conn, only: [put_status: 2]
  import Phoenix.Controller, only: [put_view: 2, render: 3]

  plug :put_root_layout, {ChiyaWeb.Layouts, :root_error}

  def render_error(conn, :not_found, assigns \\ []) do
    conn
    |> put_status(:not_found)
    |> put_view(ChiyaWeb.ErrorHTML)
    |> render("404.html", assigns)
  end
end
