defmodule ChiyaWeb.SettingControllerTest do
  use ChiyaWeb.ConnCase

  import Chiya.SiteFixtures

  @create_attrs %{
    custom_css: "some custom_css",
    custom_html: "some custom_html",
    subtitle: "some subtitle",
    theme: :default,
    title: "some title",
    user_agent: "some user_agent"
  }
  @update_attrs %{
    custom_css: "some updated custom_css",
    custom_html: "some updated custom_html",
    subtitle: "some updated subtitle",
    theme: :default,
    title: "some updated title",
    user_agent: "some updated user_agent"
  }
  @invalid_attrs %{
    custom_css: nil,
    custom_html: nil,
    subtitle: nil,
    theme: nil,
    title: nil,
    user_agent: nil
  }

  setup [:register_and_log_in_user]

  describe "new setting" do
    test "renders form", %{conn: conn} do
      conn = get(conn, ~p"/admin/settings/new")
      assert html_response(conn, 200) =~ "New Setting"
    end
  end

  describe "create setting" do
    test "redirects to show when data is valid", %{conn: conn} do
      conn = post(conn, ~p"/admin/settings", setting: @create_attrs)
      assert redirected_to(conn) == ~p"/admin/settings"
    end

    test "renders errors when data is invalid", %{conn: conn} do
      conn = post(conn, ~p"/admin/settings", setting: @invalid_attrs)
      assert html_response(conn, 200) =~ "New Setting"
    end
  end

  describe "edit setting" do
    setup [:create_setting]

    test "renders form for editing chosen setting", %{conn: conn} do
      conn = get(conn, ~p"/admin/settings/edit")
      assert html_response(conn, 200) =~ "Edit Setting"
    end
  end

  describe "update setting" do
    setup [:create_setting]

    test "redirects when data is valid", %{conn: conn} do
      conn = put(conn, ~p"/admin/settings", setting: @update_attrs)
      assert redirected_to(conn) == ~p"/admin/settings"

      conn = get(conn, ~p"/admin/settings")
      assert html_response(conn, 200) =~ "some updated custom_css"
    end

    test "renders errors when data is invalid", %{conn: conn} do
      conn = put(conn, ~p"/admin/settings", setting: @invalid_attrs)
      assert html_response(conn, 200) =~ "Edit Setting"
    end
  end

  defp create_setting(_) do
    setting = setting_fixture()
    %{setting: setting}
  end
end
