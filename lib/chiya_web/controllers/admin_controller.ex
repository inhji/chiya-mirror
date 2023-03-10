defmodule ChiyaWeb.AdminController do
  use ChiyaWeb, :controller

  def home(conn, _params) do
    render(conn, :home)
  end
end
