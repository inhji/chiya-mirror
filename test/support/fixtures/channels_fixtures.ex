defmodule Chiya.ChannelsFixtures do
  @moduledoc """
  This module defines test helpers for creating
  entities via the `Chiya.Channels` context.
  """

  @doc """
  Generate a unique note slug.
  """
  def unique_channel_slug, do: "some slug#{System.unique_integer([:positive])}"

  @doc """
  Generate a channel.
  """
  def channel_fixture(attrs \\ %{}) do
    {:ok, channel} =
      attrs
      |> Enum.into(%{
        content: "some content",
        name: "some name",
        slug: unique_channel_slug(),
        visibility: :public
      })
      |> Chiya.Channels.create_channel()

    channel
  end
end
