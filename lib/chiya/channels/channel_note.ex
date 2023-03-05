defmodule Chiya.Channels.ChannelNote do
  use Ecto.Schema
  import Ecto.Changeset

  schema "channels_notes" do

    field :channel, :id
    field :note, :id

    timestamps()
  end

  @doc false
  def changeset(channel_note, attrs) do
    channel_note
    |> cast(attrs, [])
    |> validate_required([])
  end
end
