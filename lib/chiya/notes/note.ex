defmodule Chiya.Notes.Note do
  use Ecto.Schema
  import Ecto.Changeset
  alias Chiya.Notes.NoteSlug

  @reserved_slugs []

  @derive {Jason.Encoder, only: [:id, :name, :content, :slug, :channels]}
  schema "notes" do
    field :content, :string

    field :kind, Ecto.Enum,
      values: [:post, :bookmark],
      default: :post

    field :name, :string
    field :published_at, :naive_datetime
    field :slug, NoteSlug.Type
    field :url, :string

    many_to_many :channels, Chiya.Channels.Channel,
      join_through: "channels_notes",
      join_keys: [note: :id, channel: :id],
      on_replace: :delete

    many_to_many :links_from, Chiya.Notes.Note,
      join_through: Chiya.Notes.NoteNote,
      join_keys: [target_id: :id, source_id: :id]

    many_to_many :links_to, Chiya.Notes.Note,
      join_through: Chiya.Notes.NoteNote,
      join_keys: [source_id: :id, target_id: :id]

    has_many :images, Chiya.Notes.NoteImage

    timestamps()
  end

  @doc false
  def changeset(note, attrs) do
    note
    |> Chiya.Notes.preload_note()
    |> cast(attrs, [:name, :content, :slug, :published_at, :kind, :url])
    |> put_assoc(:channels, attrs["channels"] || [])
    |> NoteSlug.maybe_generate_slug()
    |> NoteSlug.unique_constraint()
    |> validate_required([:name, :content, :slug, :kind])
    |> validate_exclusion(:slug, @reserved_slugs)
  end
end
