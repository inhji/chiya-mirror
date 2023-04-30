defmodule Chiya.Notes.NoteComment do
  use Ecto.Schema
  import Ecto.Changeset

  schema "note_comments" do
    field :approved_at, :naive_datetime
    field :author_name, :string
    field :author_id, :id
    field :content, :string
    field :kind, Ecto.Enum, values: [:anon, :fedi], default: :anon

    belongs_to :note, Chiya.Notes.Note

    timestamps()
  end

  @doc false
  def changeset(note_comment, attrs) do
    note_comment
    |> cast(attrs, [:content, :author_name, :author_id, :kind, :note_id, :approved_at])
    |> validate_required([:content, :author_name, :kind, :note_id])
  end
end
