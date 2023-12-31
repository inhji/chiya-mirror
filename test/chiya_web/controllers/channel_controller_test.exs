defmodule ChiyaWeb.ChannelControllerTest do
  use ChiyaWeb.ConnCase

  import Chiya.ChannelsFixtures

  @create_attrs %{
    content: "some content",
    name: "some name",
    slug: "some slug",
    layout: :default,
    visibility: :public
  }
  @update_attrs %{
    content: "some updated content",
    name: "some updated name",
    slug: "some updated slug",
    layout: :default,
    visibility: :private
  }
  @invalid_attrs %{content: nil, name: nil, slug: nil, visibility: nil}

  setup [:register_and_log_in_user]

  describe "index" do
    test "lists all channels", %{conn: conn} do
      conn = get(conn, ~p"/admin/channels")
      assert html_response(conn, 200) =~ "Channels"
    end
  end

  describe "new channel" do
    test "renders form", %{conn: conn} do
      conn = get(conn, ~p"/admin/channels/new")
      assert html_response(conn, 200) =~ "New Channel"
    end
  end

  describe "create channel" do
    test "redirects to show when data is valid", %{conn: conn} do
      conn = post(conn, ~p"/admin/channels", channel: @create_attrs)

      assert %{id: id} = redirected_params(conn)
      assert redirected_to(conn) == ~p"/admin/channels/#{id}"

      conn = get(conn, ~p"/admin/channels/#{id}")
      assert html_response(conn, 200) =~ "Channel #{id}"
    end

    test "renders errors when data is invalid", %{conn: conn} do
      conn = post(conn, ~p"/admin/channels", channel: @invalid_attrs)
      assert html_response(conn, 200) =~ "New Channel"
    end
  end

  describe "edit channel" do
    setup [:create_channel]

    test "renders form for editing chosen channel", %{conn: conn, channel: channel} do
      conn = get(conn, ~p"/admin/channels/#{channel}/edit")
      assert html_response(conn, 200) =~ "Edit Channel"
    end
  end

  describe "update channel" do
    setup [:create_channel]

    test "redirects when data is valid", %{conn: conn, channel: channel} do
      conn = put(conn, ~p"/admin/channels/#{channel}", channel: @update_attrs)
      assert redirected_to(conn) == ~p"/admin/channels/#{channel}"

      conn = get(conn, ~p"/admin/channels/#{channel}")
      assert html_response(conn, 200) =~ "some updated content"
    end

    test "renders errors when data is invalid", %{conn: conn, channel: channel} do
      conn = put(conn, ~p"/admin/channels/#{channel}", channel: @invalid_attrs)
      assert html_response(conn, 200) =~ "Edit Channel"
    end
  end

  describe "delete channel" do
    setup [:create_channel]

    test "deletes chosen channel", %{conn: conn, channel: channel} do
      conn = delete(conn, ~p"/admin/channels/#{channel}")
      assert redirected_to(conn) == ~p"/admin/channels"

      assert_error_sent 404, fn ->
        get(conn, ~p"/admin/channels/#{channel}")
      end
    end
  end

  defp create_channel(_) do
    channel = channel_fixture()
    %{channel: channel}
  end
end
