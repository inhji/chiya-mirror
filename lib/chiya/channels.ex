defmodule Chiya.Channels do
  @moduledoc """
  The Channels context.
  """

  import Ecto.Query, warn: false
  alias Chiya.Repo
  alias Chiya.Channels.Channel
  alias Chiya.Notes.Note

  @preloads [:notes]
  @public_preloads [
    notes:
      from(n in Note,
        where: not is_nil(n.published_at),
        order_by: [desc: n.published_at]
      )
  ]

  @doc """
  Returns the list of channels.

  ## Examples

      iex> list_channels()
      [%Channel{}, ...]

  """
  def list_channels do
    Channel
    |> order_by(desc: :visibility)
    |> Repo.all()
  end

  def preload_channel(channel), do: Repo.preload(channel, @preloads)
  def preload_channel_public(channel), do: Repo.preload(channel, @public_preloads)

  @doc """
  Gets a single channel.

  Raises `Ecto.NoResultsError` if the Channel does not exist.

  ## Examples

      iex> get_channel!(123)
      %Channel{}

      iex> get_channel!(456)
      ** (Ecto.NoResultsError)

  """
  def get_channel!(id), do: Repo.get!(Channel, id)

  @doc """
  Gets a single channel with all associated entities preloaded.
  """
  def get_channel_preloaded!(id), do: Repo.get!(Channel, id) |> preload_channel()

  @doc """
  Gets a single channel by its slug with all associated entities preloaded.
  """
  def get_channel_by_slug!(slug), do: Repo.get_by!(Channel, slug: slug)

  @doc """
  Creates a channel.

  ## Examples

      iex> create_channel(%{field: value})
      {:ok, %Channel{}}

      iex> create_channel(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_channel(attrs \\ %{}) do
    %Channel{}
    |> Channel.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Updates a channel.

  ## Examples

      iex> update_channel(channel, %{field: new_value})
      {:ok, %Channel{}}

      iex> update_channel(channel, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_channel(%Channel{} = channel, attrs) do
    channel
    |> Channel.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a channel.

  ## Examples

      iex> delete_channel(channel)
      {:ok, %Channel{}}

      iex> delete_channel(channel)
      {:error, %Ecto.Changeset{}}

  """
  def delete_channel(%Channel{} = channel) do
    Repo.delete(channel)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking channel changes.

  ## Examples

      iex> change_channel(channel)
      %Ecto.Changeset{data: %Channel{}}

  """
  def change_channel(%Channel{} = channel, attrs \\ %{}) do
    Channel.changeset(channel, attrs)
  end
end
