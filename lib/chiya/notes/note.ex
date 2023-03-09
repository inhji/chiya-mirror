defmodule Chiya.Notes.Note do
  use Ecto.Schema
  import Ecto.Changeset

  schema "notes" do
    field :content, :string
    field :kind, Ecto.Enum, values: [:post, :bookmark]
    field :name, :string
    field :published_at, :naive_datetime
    field :slug, :string
    field :url, :string

    many_to_many :channels, Chiya.Channels.Channel,
      # join_through: Chiya.Channels.ChannelNote,
      join_through: "channels_notes",
      join_keys: [note: :id, channel: :id],
      on_replace: :delete

    has_many :images, Chiya.Notes.NoteImage

    timestamps()
  end

  @doc false
  def changeset(note, attrs) do
    note
    |> Chiya.Notes.preload_note()
    |> cast(attrs, [:name, :content, :slug, :published_at, :kind, :url])
    |> put_assoc(:channels, attrs["channels"] || [])
    |> validate_required([:name, :content, :slug, :published_at, :kind, :url])
    |> unique_constraint(:slug)
  end
end
