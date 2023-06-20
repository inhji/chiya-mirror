defmodule Chiya.Notes.Note do
  use Ecto.Schema
  import Ecto.Changeset
  alias Chiya.Notes.{Note, NoteSlug, NoteNote, NoteTag}

  use Phoenix.VerifiedRoutes,
    endpoint: ChiyaWeb.Endpoint,
    router: ChiyaWeb.Router,
    statics: ChiyaWeb.static_paths()

  @reserved_slugs ~w(user admin dev api)
  @note_url_regex ~r/\/note\/([a-z0-9-]+)/

  @derive {Jason.Encoder, only: [:id, :name, :content, :slug, :channels, :tags]}
  schema "notes" do
    field :content, :string

    field :kind, Ecto.Enum,
      values: [:post, :bookmark, :recipe],
      default: :post

    field :name, :string
    field :published_at, :naive_datetime
    field :slug, NoteSlug.Type
    field :url, :string

    many_to_many :channels, Chiya.Channels.Channel,
      join_through: "channels_notes",
      join_keys: [note: :id, channel: :id],
      on_replace: :delete

    many_to_many :links_from, Note,
      join_through: NoteNote,
      join_keys: [source_id: :id, target_id: :id]

    many_to_many :links_to, Note,
      join_through: NoteNote,
      join_keys: [target_id: :id, source_id: :id]

    many_to_many :tags, Chiya.Tags.Tag,
      join_through: NoteTag,
      join_keys: [note_id: :id, tag_id: :id]

    has_many :images, Chiya.Notes.NoteImage
    has_many :comments, Chiya.Notes.NoteComment

    field :tags_string, :string,
      virtual: true,
      default: ""

    timestamps()
  end

  def note_path(note) do
    ~p"/note/#{note.slug}"
  end

  def note_url(note) do
    Phoenix.VerifiedRoutes.url(~p"/note/#{note.slug}")
  end

  def note_slug(note_url) do
    case Regex.run(@note_url_regex, note_url) do
      nil -> {:error, nil}
      [_full, slug] -> {:ok, slug}
    end
  end

  @doc false
  def changeset(note, attrs) do
    # if you need to have a preloaded note here,
    # do it yourself before you come here. now GET OUT.

    note
    |> cast(attrs, [:name, :content, :slug, :published_at, :kind, :url])
    |> put_assoc(:channels, attrs["channels"] || attrs[:channels] || [])
    |> NoteSlug.maybe_generate_slug()
    |> NoteSlug.unique_constraint()
    |> validate_required([:name, :content, :slug, :kind])
    |> validate_exclusion(:slug, @reserved_slugs)
  end
end
