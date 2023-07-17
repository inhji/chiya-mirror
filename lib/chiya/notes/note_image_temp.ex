defmodule Chiya.Notes.NoteImageTemp do
  use Ecto.Schema
  use Waffle.Ecto.Schema
  import Ecto.Changeset

  schema "note_images_temp" do
    field :content, :string, default: ""
    field :path, ChiyaWeb.Uploaders.NoteImage.Type

    timestamps()
  end

  @doc false
  def changeset(note_image, attrs) do
    note_image
    |> cast(attrs, [:content])
    |> cast_attachments(attrs, [:path], allow_paths: true)
    |> validate_required([:path])
  end
end
