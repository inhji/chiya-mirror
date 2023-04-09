defmodule Chiya.Notes.NoteNote do
  @moduledoc """
  The NoteNote module
  """
  use Ecto.Schema
  import Ecto.Changeset

  schema "notes_notes" do
    belongs_to :source, Chiya.Notes.Note
    belongs_to :target, Chiya.Notes.Note
  end

  @doc false
  def changeset(note_note, attrs) do
    note_note
    |> cast(attrs, [:source_id, :target_id])
    |> validate_required([:source_id, :target_id])
  end
end
