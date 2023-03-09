defmodule ChiyaWeb.IdentityController do
  use ChiyaWeb, :controller

  alias Chiya.Identities
  alias Chiya.Identities.Identity

  def index(conn, _params) do
    identities = Identities.list_identities()
    render(conn, :index, identities: identities)
  end

  def new(conn, _params) do
    changeset = Identities.change_identity(%Identity{})
    render(conn, :new, changeset: changeset)
  end

  def create(conn, %{"identity" => identity_params}) do
    case Identities.create_identity(identity_params) do
      {:ok, identity} ->
        conn
        |> put_flash(:info, "Identity created successfully.")
        |> redirect(to: ~p"/admin/identities/#{identity}")

      {:error, %Ecto.Changeset{} = changeset} ->
        render(conn, :new, changeset: changeset)
    end
  end

  def show(conn, %{"id" => id}) do
    identity = Identities.get_identity!(id)
    render(conn, :show, identity: identity)
  end

  def edit(conn, %{"id" => id}) do
    identity = Identities.get_identity!(id)
    changeset = Identities.change_identity(identity)
    render(conn, :edit, identity: identity, changeset: changeset)
  end

  def update(conn, %{"id" => id, "identity" => identity_params}) do
    identity = Identities.get_identity!(id)

    case Identities.update_identity(identity, identity_params) do
      {:ok, identity} ->
        conn
        |> put_flash(:info, "Identity updated successfully.")
        |> redirect(to: ~p"/admin/identities/#{identity}")

      {:error, %Ecto.Changeset{} = changeset} ->
        render(conn, :edit, identity: identity, changeset: changeset)
    end
  end

  def delete(conn, %{"id" => id}) do
    identity = Identities.get_identity!(id)
    {:ok, _identity} = Identities.delete_identity(identity)

    conn
    |> put_flash(:info, "Identity deleted successfully.")
    |> redirect(to: ~p"/admin/identities")
  end
end
