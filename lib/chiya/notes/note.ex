defmodule Chiya.Notes.Note do
  use Ecto.Schema
  import Ecto.Changeset

  schema "notes" do
    field :content, :string
    field :kind, :string
    field :name, :string
    field :published_at, :naive_datetime
    field :slug, :string
    field :url, :string

    many_to_many :channels, Chiya.Channels.Channel, join_through: "channels_notes"

    timestamps()
  end

  @doc false
  def changeset(note, attrs) do
    note
    |> cast(attrs, [:name, :content, :slug, :published_at, :kind, :url])
    |> validate_required([:name, :content, :slug, :published_at, :kind, :url])
    |> unique_constraint(:slug)
  end
end
