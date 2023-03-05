defmodule Chiya.Channels.Channel do
  use Ecto.Schema
  import Ecto.Changeset

  schema "channels" do
    field :content, :string
    field :name, :string
    field :slug, :string
    field :visibility, Ecto.Enum, values: [:public, :private, :unlisted]

    timestamps()
  end

  @doc false
  def changeset(channel, attrs) do
    channel
    |> cast(attrs, [:name, :content, :visibility, :slug])
    |> validate_required([:name, :content, :visibility, :slug])
  end
end
