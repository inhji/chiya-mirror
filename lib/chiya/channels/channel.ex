defmodule Chiya.Channels.Channel do
  use Ecto.Schema
  import Ecto.Changeset
  alias Chiya.Channels.ChannelSlug

  @derive {Jason.Encoder, only: [:name]}
  schema "channels" do
    field :content, :string
    field :name, :string
    field :slug, ChannelSlug.Type

    field :visibility, Ecto.Enum,
      values: [
        :public,
        :private,
        :unlisted
      ],
      default: :private

    field :layout, Ecto.Enum,
      values: [
        :default,
        :microblog,
        :gallery
      ],
      default: :default

    many_to_many :notes, Chiya.Notes.Note,
      join_through: "channels_notes",
      join_keys: [channel: :id, note: :id]

    timestamps()
  end

  @doc false
  def changeset(channel, attrs) do
    channel
    |> cast(attrs, [:name, :content, :visibility, :slug, :layout])
    |> ChannelSlug.maybe_generate_slug()
    |> ChannelSlug.unique_constraint()
    |> validate_required([:name, :content, :visibility, :slug, :layout])
    |> validate_exclusion(:slug, ~w(admin user dev))
  end

  def icon(%Chiya.Channels.Channel{visibility: visibility}) do
    case(visibility) do
      :private -> "🔒"
      :public -> "🌍"
      :unlisted -> "👁️"
    end
  end
end
