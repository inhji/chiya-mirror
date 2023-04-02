defmodule Chiya.NotesTest do
  use Chiya.DataCase

  import Chiya.NotesFixtures

  alias Chiya.Notes
  alias Chiya.Notes.Note

  describe "notes" do
    @invalid_attrs %{content: nil, kind: nil, name: nil, published_at: nil, slug: nil, url: nil}

    test "list_notes/0 returns all notes" do
      note = note_fixture()
      assert Notes.list_notes() == [note]
    end

    test "get_note!/1 returns the note with given id" do
      note = note_fixture()
      assert Notes.get_note_preloaded!(note.id) == note
    end

    test "create_note/1 with valid data creates a note" do
      valid_attrs = %{
        content: "some content",
        kind: "post",
        name: "some name",
        published_at: ~N[2023-03-04 16:22:00],
        url: "some url"
      }

      assert {:ok, %Note{} = note} = Notes.create_note(valid_attrs)
      assert note.content == "some content"
      assert note.kind == :post
      assert note.name == "some name"
      assert note.published_at == ~N[2023-03-04 16:22:00]
      assert note.slug == "some-name"
      assert note.url == "some url"
    end

    test "create_note/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Notes.create_note(@invalid_attrs)
    end

    test "update_note/2 with valid data updates the note" do
      note = note_fixture()

      update_attrs = %{
        content: "some updated content",
        kind: "bookmark",
        name: "some updated name",
        published_at: ~N[2023-03-05 16:22:00],
        slug: "some updated slug",
        url: "some updated url"
      }

      assert {:ok, %Note{} = note} = Notes.update_note(note, update_attrs)
      assert note.content == "some updated content"
      assert note.kind == :bookmark
      assert note.name == "some updated name"
      assert note.published_at == ~N[2023-03-05 16:22:00]
      assert note.slug == "some updated slug"
      assert note.url == "some updated url"
    end

    test "update_note/2 with invalid data returns error changeset" do
      note = note_fixture()
      assert {:error, %Ecto.Changeset{}} = Notes.update_note(note, @invalid_attrs)
      assert note == Notes.get_note_preloaded!(note.id)
    end

    test "delete_note/1 deletes the note" do
      note = note_fixture()
      assert {:ok, %Note{}} = Notes.delete_note(note)
      assert_raise Ecto.NoResultsError, fn -> Notes.get_note!(note.id) end
    end

    test "change_note/1 returns a note changeset" do
      note = note_fixture()
      assert %Ecto.Changeset{} = Notes.change_note(note)
    end
  end
end
