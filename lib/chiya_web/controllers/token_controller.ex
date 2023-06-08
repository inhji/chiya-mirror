defmodule ChiyaWeb.TokenController do
  use ChiyaWeb, :controller

  alias Chiya.Accounts.UserToken

  def index(conn, _params) do
    tokens = conn.assigns.current_user.tokens
    render(conn, :index, tokens: tokens)
  end

  def show(conn, %{"id" => id}) do
    token_id = String.to_integer(id)
    tokens = conn.assigns.current_user.tokens
    token = Enum.find(tokens, fn t -> t.id == token_id end)
    render(conn, :show, token: token)
  end

  def new(conn, _params) do
    changeset =
      UserToken.app_token_changeset(%UserToken{}, %{
        user_id: conn.assigns.current_user.id,
        context: "app"
      })

    render(conn, :new, changeset: changeset)
  end

  def create(conn, %{"user_token" => %{"sent_to" => app_name, "context" => context}}) do
    case Chiya.Accounts.generate_app_token(conn.assigns.current_user, app_name, context) do
      {:ok, token} ->
        conn
        |> put_flash(:info, "token created successfully.")
        |> redirect(to: ~p"/admin/tokens/#{token}")

      {:error, %Ecto.Changeset{} = changeset} ->
        render(conn, :new, changeset: changeset)
    end
  end

  def delete(conn, %{"id" => id}) do
    {:ok, _token} = Chiya.Accounts.delete_app_token(id)

    conn
    |> put_flash(:info, "Token deleted successfully.")
    |> redirect(to: ~p"/admin/tokens")
  end
end
