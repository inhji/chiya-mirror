defmodule Chiya.Notes.NoteImage do
  use Ecto.Schema
  use Waffle.Ecto.Schema
  import Ecto.Changeset

  @attachment_options [
    allow_paths: true,
    allow_urls: true
  ]

  schema "note_images" do
    field :content, :string, default: ""
    field :path, ChiyaWeb.Uploaders.NoteImage.Type
    field :featured, :boolean, default: false

    belongs_to :note, Chiya.Notes.Note

    timestamps()
  end

  @doc false
  def insert_changeset(note_image, attrs) do
    note_image
    |> cast(attrs, [:note_id])
    |> validate_required([:note_id])
  end

  @doc false
  def update_changeset(note_image, attrs) do
    note_image
    |> cast(attrs, [:content, :note_id, :featured])
    |> cast_attachments(attrs, [:path], @attachment_options)
    |> validate_required([:path, :note_id])
  end
end
