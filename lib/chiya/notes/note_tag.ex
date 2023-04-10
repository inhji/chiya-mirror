defmodule Chiya.Notes.NoteTag do
  @moduledoc """
  The NoteTag module
  """
  use Ecto.Schema
  import Ecto.Changeset

  schema "notes_tags" do
    belongs_to :note, Chiya.Notes.Note
    belongs_to :tag, Chiya.Tags.Tag
  end

  @doc false
  def changeset(note_tag, attrs) do
    note_tag
    |> cast(attrs, [:note_id, :tag_id])
    |> validate_required([:note_id, :tag_id])
  end
end
