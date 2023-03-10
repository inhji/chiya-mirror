defmodule Chiya.Channels.Channel do
  use Ecto.Schema
  import Ecto.Changeset

  schema "channels" do
    field :content, :string
    field :name, :string
    field :slug, :string
    field :visibility, Ecto.Enum, values: [:public, :private, :unlisted]

    many_to_many :notes, Chiya.Notes.Note,
      join_through: "channels_notes",
      join_keys: [note: :id, channel: :id]
    
    timestamps()
  end

  @doc false
  def changeset(channel, attrs) do
    channel
    |> cast(attrs, [:name, :content, :visibility, :slug])
    |> validate_required([:name, :content, :visibility, :slug])
    |> validate_exclusion(:slug, ~w(admin user dev))
    |> unique_constraint(:slug)
  end
end
