defmodule Chiya.NoteTest do
  use Chiya.DataCase
  alias Chiya.Notes.Note

  @content1 "This is a short title"
  @content2 "This is a title that is a lot longer than the first and does not contain a dot"
  @content3 "This is a title. It contains dots and should be cut at the first of the dots."
  @content4 "This used to be some funny title"

  describe "note_title" do
    test "returns a short text completely" do
      assert Note.note_title(@content1) == @content1
    end

    test "returns a longer text until 7 words " do
      title = Note.note_title(@content2)
      assert title == "This is a title that is a"

      title = Note.note_title(@content4)
      assert title == "This used to be some funny title"
    end

    test "returns a longer text until the first dot" do
      title = Note.note_title(@content3)
      assert title == "This is a title"
    end
  end
end
