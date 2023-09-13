defmodule Chiya.Tags do
  @moduledoc """
  The Tags context.
  """

  import Ecto.Query, warn: false
  alias Chiya.Repo

  alias Chiya.Tags.Tag

  @preloads [notes: [tags: [:notes]]]
  defp with_preloads(query), do: preload(query, ^@preloads)

  @doc """
  Preloads a tag with all defined preloads.

  ## Examples

      iex> preload_tag(tag)
      %Tag{}

  """
  def preload_tag(tag), do: Repo.preload(tag, @preloads)

  @doc """
  Returns the list of tags.

  ## Examples

      iex> list_tags()
      [%Tag{}, ...]

  """
  def list_tags do
    Tag
    |> with_preloads()
    |> order_by(:name)
    |> Repo.all()
  end

  def list_admin_tags() do
    q =
      Tag
      |> order_by(:name)
      |> with_preloads()

    Repo.all(q)
  end

  def get_tag!(id), do: Repo.get!(Tag, id) |> preload_tag()

  @doc """
  Gets a single tag.

  Raises `Ecto.NoResultsError` if the Tag does not exist.

  ## Examples

      iex> get_tag!(123)
      %Tag{}

      iex> get_tag!(456)
      ** (Ecto.NoResultsError)

  """
  def get_tag_by_slug!(slug), do: Repo.get_by!(Tag, slug: slug) |> preload_tag()

  @doc """
  Gets a single tag.

  Returns nil if the Tag does not exist.

  ## Examples

      iex> get_tag(123)
      %Tag{}

      iex> get_tag(456)
      nil
  """
  def get_tag_by_slug(slug), do: Repo.get_by(Tag, slug: slug) |> preload_tag()

  @doc """
  Creates a tag.

  ## Examples

      iex> create_tag(%{field: value})
      {:ok, %Tag{}}

      iex> create_tag(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_tag(attrs \\ %{}) do
    %Tag{}
    |> Tag.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Updates a tag.

  ## Examples

      iex> update_tag(tag, %{field: new_value})
      {:ok, %Tag{}}

      iex> update_tag(tag, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_tag(%Tag{} = tag, attrs) do
    tag
    |> Tag.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a tag.

  ## Examples

      iex> delete_tag(tag)
      {:ok, %Tag{}}

      iex> delete_tag(tag)
      {:error, %Ecto.Changeset{}}

  """
  def delete_tag(%Tag{} = tag) do
    Repo.delete(tag)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking tag changes.

  ## Examples

      iex> change_tag(tag)
      %Ecto.Changeset{data: %Tag{}}

  """
  def change_tag(%Tag{} = tag, attrs \\ %{}) do
    Tag.changeset(tag, attrs)
  end
end
