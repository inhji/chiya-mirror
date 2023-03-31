defmodule ChiyaWeb.IdentityControllerTest do
  use ChiyaWeb.ConnCase

  import Chiya.IdentitiesFixtures

  @create_attrs %{
    active: true,
    name: "some name",
    public: true,
    rel: "some rel",
    url: "some url",
    icon: "some icon"
  }
  @update_attrs %{
    active: false,
    name: "some updated name",
    public: false,
    rel: "some updated rel",
    url: "some updated url",
    icon: "some updated icon"
  }
  @invalid_attrs %{active: nil, name: nil, public: nil, rel: nil, url: nil}

  setup [:register_and_log_in_user]

  describe "index" do
    test "lists all identities", %{conn: conn} do
      conn = get(conn, ~p"/admin/identities")
      assert html_response(conn, 200) =~ "Listing Identities"
    end
  end

  describe "new identity" do
    test "renders form", %{conn: conn} do
      conn = get(conn, ~p"/admin/identities/new")
      assert html_response(conn, 200) =~ "New Identity"
    end
  end

  describe "create identity" do
    test "redirects to show when data is valid", %{conn: conn} do
      conn = post(conn, ~p"/admin/identities", identity: @create_attrs)

      assert %{id: id} = redirected_params(conn)
      assert redirected_to(conn) == ~p"/admin/identities/#{id}"

      conn = get(conn, ~p"/admin/identities/#{id}")
      assert html_response(conn, 200) =~ "Identity #{id}"
    end

    test "renders errors when data is invalid", %{conn: conn} do
      conn = post(conn, ~p"/admin/identities", identity: @invalid_attrs)
      assert html_response(conn, 200) =~ "New Identity"
    end
  end

  describe "edit identity" do
    setup [:create_identity]

    test "renders form for editing chosen identity", %{conn: conn, identity: identity} do
      conn = get(conn, ~p"/admin/identities/#{identity}/edit")
      assert html_response(conn, 200) =~ "Edit Identity"
    end
  end

  describe "update identity" do
    setup [:create_identity]

    test "redirects when data is valid", %{conn: conn, identity: identity} do
      conn = put(conn, ~p"/admin/identities/#{identity}", identity: @update_attrs)
      assert redirected_to(conn) == ~p"/admin/identities/#{identity}"

      conn = get(conn, ~p"/admin/identities/#{identity}")
      assert html_response(conn, 200) =~ "some updated name"
    end

    test "renders errors when data is invalid", %{conn: conn, identity: identity} do
      conn = put(conn, ~p"/admin/identities/#{identity}", identity: @invalid_attrs)
      assert html_response(conn, 200) =~ "Edit Identity"
    end
  end

  describe "delete identity" do
    setup [:create_identity]

    test "deletes chosen identity", %{conn: conn, identity: identity} do
      conn = delete(conn, ~p"/admin/identities/#{identity}")
      assert redirected_to(conn) == ~p"/admin/identities"

      assert_error_sent 404, fn ->
        get(conn, ~p"/admin/identities/#{identity}")
      end
    end
  end

  defp create_identity(_) do
    identity = identity_fixture()
    %{identity: identity}
  end
end
