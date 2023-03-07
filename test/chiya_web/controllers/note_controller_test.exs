defmodule ChiyaWeb.NoteControllerTest do
  use ChiyaWeb.ConnCase

  import Chiya.NotesFixtures

  @create_attrs %{
    content: "some content",
    kind: "post",
    name: "some name",
    published_at: ~N[2023-03-04 16:22:00],
    slug: "some slug",
    url: "some url"
  }
  @update_attrs %{
    content: "some updated content",
    kind: "bookmark",
    name: "some updated name",
    published_at: ~N[2023-03-05 16:22:00],
    slug: "some updated slug",
    url: "some updated url"
  }
  @invalid_attrs %{content: nil, kind: nil, name: nil, published_at: nil, slug: nil, url: nil}

  setup [:register_and_log_in_user]

  describe "index" do
    test "lists all notes", %{conn: conn} do
      conn = get(conn, ~p"/admin/notes")
      assert html_response(conn, 200) =~ "Listing Notes"
    end
  end

  describe "new note" do
    test "renders form", %{conn: conn} do
      conn = get(conn, ~p"/admin/notes/new")
      assert html_response(conn, 200) =~ "New Note"
    end
  end

  describe "create note" do
    test "redirects to show when data is valid", %{conn: conn} do
      conn = post(conn, ~p"/admin/notes", note: @create_attrs)

      assert %{id: id} = redirected_params(conn)
      assert redirected_to(conn) == ~p"/admin/notes/#{id}"

      conn = get(conn, ~p"/admin/notes/#{id}")
      assert html_response(conn, 200) =~ "Note #{id}"
    end

    test "renders errors when data is invalid", %{conn: conn} do
      conn = post(conn, ~p"/admin/notes", note: @invalid_attrs)
      assert html_response(conn, 200) =~ "New Note"
    end
  end

  describe "create note with channel" do
    setup [:create_channels]

    test "redirects to show when selecting a channel", %{conn: conn, channel: channel} do
      attrs = Map.put_new(@create_attrs, :channels, [to_string(channel.id)])
      conn = post(conn, ~p"/admin/notes", note: attrs)

      assert %{id: id} = redirected_params(conn)
      assert redirected_to(conn) == ~p"/admin/notes/#{id}"

      conn = get(conn, ~p"/admin/notes/#{id}")
      assert html_response(conn, 200) =~ "Note #{id}"
    end
  end

  describe "edit note" do
    setup [:create_note]

    test "renders form for editing chosen note", %{conn: conn, note: note} do
      conn = get(conn, ~p"/admin/notes/#{note}/edit")
      assert html_response(conn, 200) =~ "Edit Note"
    end
  end

  describe "update note" do
    setup [:create_note]

    test "redirects when data is valid", %{conn: conn, note: note} do
      conn = put(conn, ~p"/admin/notes/#{note}", note: @update_attrs)
      assert redirected_to(conn) == ~p"/admin/notes/#{note}"

      conn = get(conn, ~p"/admin/notes/#{note}")
      assert html_response(conn, 200) =~ "some updated content"
    end

    test "renders errors when data is invalid", %{conn: conn, note: note} do
      conn = put(conn, ~p"/admin/notes/#{note}", note: @invalid_attrs)
      assert html_response(conn, 200) =~ "Edit Note"
    end
  end

  describe "update note with channel" do
    setup [:create_note, :create_channels]

    test "adds and removes the correct channels from the note", %{
      conn: conn,
      note: note,
      channel: channel,
      channel2: channel2
    } do
      attrs = Map.put_new(@update_attrs, :channels, [to_string(channel.id)])
      conn = put(conn, ~p"/admin/notes/#{note}", note: attrs)
      assert redirected_to(conn) == ~p"/admin/notes/#{note}"

      attrs = Map.put_new(@update_attrs, :channels, [to_string(channel2.id)])
      conn = put(conn, ~p"/admin/notes/#{note}", note: attrs)
      assert redirected_to(conn) == ~p"/admin/notes/#{note}"

      conn = get(conn, ~p"/admin/notes/#{note}")
      assert html_response(conn, 200) =~ "some updated content"
    end
  end

  describe "delete note" do
    setup [:create_note]

    test "deletes chosen note", %{conn: conn, note: note} do
      conn = delete(conn, ~p"/admin/notes/#{note}")
      assert redirected_to(conn) == ~p"/admin/notes"

      assert_error_sent 404, fn ->
        get(conn, ~p"/admin/notes/#{note}")
      end
    end
  end

  defp create_note(_) do
    note = note_fixture()
    %{note: note}
  end

  defp create_channels(_) do
    channel = Chiya.ChannelsFixtures.channel_fixture()
    channel2 = Chiya.ChannelsFixtures.channel_fixture()
    %{channel: channel, channel2: channel2}
  end
end
