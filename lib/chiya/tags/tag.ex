defmodule Chiya.Tags.Tag do
  @moduledoc """
  The Tag Schema
  """
  use Ecto.Schema
  import Ecto.Changeset
  alias Chiya.Tags.TagSlug

  @derive {Jason.Encoder, only: [:name]}
  schema "tags" do
    field :name, :string
    field :slug, TagSlug.Type

    field :content, :string

    field :icon, :string
    field :regex, :string

    many_to_many :notes, Chiya.Notes.Note, join_through: "notes_tags"

    timestamps()
  end

  @doc false
  def changeset(tag, attrs) do
    tag
    |> cast(attrs, [:name, :content, :icon, :regex])
    |> validate_required([:name])
    |> unique_constraint(:name)
    |> TagSlug.maybe_generate_slug()
    |> TagSlug.unique_constraint()
  end
end
