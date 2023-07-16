defmodule Chiya.TagUpdaterTest do
  use Chiya.DataCase

  import Chiya.NotesFixtures
  alias Chiya.Tags.TagUpdater

  describe "update_tags/2" do
    test "with a single tag updates a note with the given tag" do
      note = note_fixture()

      assert note.tags == []
      TagUpdater.update_tags(note, "foo")
      note = Chiya.Notes.get_note_preloaded!(note.id)
      assert Enum.count(note.tags) == 1
    end

    test "with a list of new tags replaces exisiting tags" do
      note = note_fixture()

      assert note.tags == []

      TagUpdater.update_tags(note, "foo")
      note = Chiya.Notes.get_note_preloaded!(note.id)
      assert Enum.count(note.tags) == 1

      TagUpdater.update_tags(note, ["bar", "baz"])
      note = Chiya.Notes.get_note_preloaded!(note.id)
      assert Enum.count(note.tags) == 2
    end

    test "with a map representing the attributes replaces existing tags" do
      note = note_fixture()

      assert note.tags == []

      TagUpdater.update_tags(note, %{tags_string: "foo,bar,baz"})
      note = Chiya.Notes.get_note_preloaded!(note.id)
      assert Enum.count(note.tags) == 3
    end

    test "with the same tags in different capitalization replaces exisiting tags" do
      note = note_fixture()
      assert note.tags == []

      TagUpdater.update_tags(note, "foo")
      note = Chiya.Notes.get_note_preloaded!(note.id)
      assert Enum.count(note.tags) == 1

      TagUpdater.update_tags(note, ["Foo"])
      note = Chiya.Notes.get_note_preloaded!(note.id)
      assert Enum.count(note.tags) == 1

      tag = List.first(note.tags)
      assert tag.name == "foo"
    end
  end
end
