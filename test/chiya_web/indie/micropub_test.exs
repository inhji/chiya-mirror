defmodule ChiyaWeb.MicropubTest do
  use Chiya.DataCase

  alias ChiyaWeb.Indie.Micropub
  alias Chiya.Notes.Note
  alias Chiya.Channels.Channel
  import Chiya.NotesFixtures

  @valid_props %{
    "content" => ["this is a test"]
  }

  describe "create_note/3" do
    test "creates a note with valid attributes" do
      assert {:ok, :created, url} =
               Micropub.create_note("entry", @valid_props)

      note = Chiya.Notes.get_note_by_slug_preloaded("this-is-a-test")

      assert url =~ note.slug
      assert %Note{} = note
      assert [%Channel{}] = note.channels
    end
  end

  describe "update_note" do
    test "updates a note by replacing content" do
      note = note_fixture()

      assert {:ok, %Note{} = note} =
               Micropub.update_note(note, %{"content" => ["replaced content"]}, %{}, %{})

      assert note.content == "replaced content"
    end

    test "updates a note by replacing name" do
      note = note_fixture()

      assert {:ok, %Note{} = note} =
               Micropub.update_note(note, %{"name" => ["replaced name"]}, %{}, %{})

      assert note.name == "replaced name"
    end

    test "updates a note by adding categories" do
      note = note_fixture()

      assert {:ok, %Note{} = note} =
               Micropub.update_note(note, %{"category" => ["foo", "bar"]}, %{}, %{})

      assert Enum.empty?(note.tags) == false
    end
  end

  setup do
    {:ok, channel} =
      Chiya.Channels.create_channel(%{
        name: "Home",
        content: "Home channel"
      })

    settings = Chiya.Site.get_settings()

    Chiya.Site.update_setting(settings, %{
      home_channel_id: channel.id,
      default_channel_id: channel.id,
      micropub_channel_id: channel.id,
      wiki_channel_id: channel.id
    })

    :ok
  end
end
