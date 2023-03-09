defmodule Chiya.Identities do
  @moduledoc """
  The Identities context.
  """

  import Ecto.Query, warn: false
  alias Chiya.Repo

  alias Chiya.Identities.Identity

  @doc """
  Returns the list of identities.

  ## Examples

      iex> list_identities()
      [%Identity{}, ...]

  """
  def list_identities do
    Repo.all(Identity)
  end

  @doc """
  Gets a single identity.

  Raises `Ecto.NoResultsError` if the Identity does not exist.

  ## Examples

      iex> get_identity!(123)
      %Identity{}

      iex> get_identity!(456)
      ** (Ecto.NoResultsError)

  """
  def get_identity!(id), do: Repo.get!(Identity, id)

  @doc """
  Creates a identity.

  ## Examples

      iex> create_identity(%{field: value})
      {:ok, %Identity{}}

      iex> create_identity(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_identity(attrs \\ %{}) do
    %Identity{}
    |> Identity.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Updates a identity.

  ## Examples

      iex> update_identity(identity, %{field: new_value})
      {:ok, %Identity{}}

      iex> update_identity(identity, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_identity(%Identity{} = identity, attrs) do
    identity
    |> Identity.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a identity.

  ## Examples

      iex> delete_identity(identity)
      {:ok, %Identity{}}

      iex> delete_identity(identity)
      {:error, %Ecto.Changeset{}}

  """
  def delete_identity(%Identity{} = identity) do
    Repo.delete(identity)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking identity changes.

  ## Examples

      iex> change_identity(identity)
      %Ecto.Changeset{data: %Identity{}}

  """
  def change_identity(%Identity{} = identity, attrs \\ %{}) do
    Identity.changeset(identity, attrs)
  end
end
