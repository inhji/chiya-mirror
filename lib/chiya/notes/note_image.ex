defmodule Chiya.Notes.NoteImage do
  use Ecto.Schema
  use Waffle.Ecto.Schema
  import Ecto.Changeset

  schema "note_images" do
    field :content, :string, default: ""
    field :path, ChiyaWeb.Uploaders.NoteImage.Type
    field :note_id, :id

    timestamps()
  end

  @doc false
  def changeset(note_image, attrs) do
    note_image
    |> cast(attrs, [:content, :note_id])
    |> cast_attachments(attrs, [:path], allow_paths: true)
    |> validate_required([:path, :note_id])
  end

  @doc false
  def insert_changeset(note_image, attrs) do
    note_image
    |> cast(attrs, [:note_id])
    |> validate_required([:note_id])
  end
end
