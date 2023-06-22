defmodule Chiya.ChannelsTest do
  use Chiya.DataCase

  import Chiya.ChannelsFixtures

  alias Chiya.Channels
  alias Chiya.Channels.Channel

  describe "channels" do
    @invalid_attrs %{content: nil, name: nil, slug: nil, visibility: nil}

    test "list_channels/0 returns all channels" do
      channel = channel_fixture()
      assert Channels.list_channels() == [channel]
    end

    test "get_channel!/1 returns the channel with given id" do
      channel = channel_fixture()
      assert Channels.get_channel!(channel.id) == channel
    end

    test "create_channel/1 with valid data creates a channel" do
      valid_attrs = %{
        content: "some content",
        name: "some name",
        visibility: :public,
        layout: :default
      }

      assert {:ok, %Channel{} = channel} = Channels.create_channel(valid_attrs)
      assert channel.content == "some content"
      assert channel.name == "some name"
      assert channel.slug == "some-name"
      assert channel.visibility == :public
    end

    test "create_channel/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Channels.create_channel(@invalid_attrs)
    end

    test "update_channel/2 with valid data updates the channel" do
      channel = channel_fixture()

      update_attrs = %{
        content: "some updated content",
        name: "some updated name",
        slug: "some updated slug",
        visibility: :private,
        layout: :default
      }

      assert {:ok, %Channel{} = channel} = Channels.update_channel(channel, update_attrs)
      assert channel.content == "some updated content"
      assert channel.name == "some updated name"
      assert channel.slug == "some updated slug"
      assert channel.visibility == :private
    end

    test "update_channel/2 with invalid data returns error changeset" do
      channel = channel_fixture()
      assert {:error, %Ecto.Changeset{}} = Channels.update_channel(channel, @invalid_attrs)
      assert channel == Channels.get_channel!(channel.id)
    end

    test "delete_channel/1 deletes the channel" do
      channel = channel_fixture()
      assert {:ok, %Channel{}} = Channels.delete_channel(channel)
      assert_raise Ecto.NoResultsError, fn -> Channels.get_channel!(channel.id) end
    end

    test "change_channel/1 returns a channel changeset" do
      channel = channel_fixture()
      assert %Ecto.Changeset{} = Channels.change_channel(channel)
    end
  end
end
