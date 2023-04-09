defmodule Chiya.Notes do
  @moduledoc """
  The Notes context.
  """

  import Ecto.Query, warn: false
  alias Chiya.Repo
  alias Chiya.Notes.{Note, NoteImage, NoteNote, References}

  @preloads [:channels, :images, :links_from, :links_to]

  @doc """
  Returns the list of notes.

  ## Examples

      iex> list_notes()
      [%Note{}, ...]

  """
  def list_notes do
    Note
    |> order_by([n], desc: n.updated_at, desc: n.published_at)
    |> Repo.all()
    |> Repo.preload(@preloads)
  end

  def list_notes_by_channel(%Chiya.Channels.Channel{} = channel) do
    Note
    |> join(:inner, [n], c in assoc(n, :channels))
    |> where([n, c], c.id == ^channel.id)
    |> order_by([n], desc: n.updated_at, desc: n.published_at)
    |> Repo.all()
    |> Repo.preload(@preloads)
  end

  @doc """
  Preloads a note

  ## Examples

      iex> preload_note(note)
      %Note{}
  """
  def preload_note(note), do: Repo.preload(note, @preloads)

  @doc """
  Gets a single note.

  Raises `Ecto.NoResultsError` if the Note does not exist.

  ## Examples

      iex> get_note!(123)
      %Note{}

      iex> get_note!(456)
      ** (Ecto.NoResultsError)

  """
  def get_note!(id), do: Repo.get!(Note, id)

  @doc """
  Gets a single note.

  Returns nil if the Note does not exist.

  ## Examples

      iex> get_note!(123)
      %Note{}

      iex> get_note!(456)
      nil

  """
  def get_note(id), do: Repo.get(Note, id)

  @doc """
  Gets a single note and preloads it.

  Raises `Ecto.NoResultsError` if the Note does not exist.

  ## Examples

      iex> get_note_preloaded!(123)
      %Note{}

      iex> get_note_preloaded!(456)
      ** (Ecto.NoResultsError)

  """
  def get_note_preloaded!(id), do: Repo.get!(Note, id) |> preload_note()

  @doc """
  Gets a single note by its slug and preloads it.

  Raises `Ecto.NoResultsError` if the Note does not exist.

  ## Examples

      iex> get_note_preloaded!(123)
      %Note{}

      iex> get_note_preloaded!(456)
      ** (Ecto.NoResultsError)

  """
  def get_note_by_slug_preloaded!(slug), do: Repo.get_by!(Note, slug: slug) |> preload_note()

  @doc """
  Gets a single note by its slug and preloads it.

  Returns nil if the Note does not exist.

  ## Examples

      iex> get_note_preloaded!(123)
      %Note{}

      iex> get_note_preloaded!(456)
      nil

  """
  def get_note_by_slug_preloaded(slug), do: Repo.get_by(Note, slug: slug) |> preload_note()

  @doc """
  Creates a note.

  ## Examples

      iex> create_note(%{field: value})
      {:ok, %Note{}}

      iex> create_note(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_note(attrs \\ %{}) do
    %Note{}
    |> Note.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Updates a note.

  ## Examples

      iex> update_note(note, %{field: new_value})
      {:ok, %Note{}}

      iex> update_note(note, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_note(%Note{} = note, attrs) do
    note
    |> Note.changeset(attrs)
    |> Repo.update()
    |> Chiya.Notes.References.update_references(attrs)
  end

  @doc """
  Deletes a note.

  ## Examples

      iex> delete_note(note)
      {:ok, %Note{}}

      iex> delete_note(note)
      {:error, %Ecto.Changeset{}}

  """
  def delete_note(%Note{} = note) do
    Repo.delete(note)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking note changes.

  ## Examples

      iex> change_note(note)
      %Ecto.Changeset{data: %Note{}}

  """
  def change_note(%Note{} = note, attrs \\ %{}) do
    Note.changeset(note, attrs)
  end

  @doc """
  Gets a single note image.
  """
  def get_note_image!(id), do: Repo.get!(NoteImage, id) |> Repo.preload(:note)

  @doc """
  Creates a note image and attaches it to a note.
  """
  def create_note_image(attrs) do
    case %NoteImage{}
         |> NoteImage.insert_changeset(attrs)
         |> Repo.insert() do
      {:ok, note_image} ->
        note_image
        |> NoteImage.update_changeset(attrs)
        |> Repo.update()

      {:error, changeset} ->
        {:error, changeset}
    end
  end

  def update_note_image(%NoteImage{} = note_image, attrs) do
    note_image
    |> NoteImage.update_changeset(attrs)
    |> Repo.update()
  end

  def delete_note_image(%NoteImage{} = note_image) do
    {:ok, _} = Repo.delete(note_image)
    :ok = ChiyaWeb.Uploaders.NoteImage.delete({note_image.path, note_image})
    :ok
  end

  def get_note_note!(attrs \\ %{}) do
    Repo.get_by!(NoteNote, attrs)
  end

  def get_note_note(attrs \\ %{}) do
    Repo.get_by(NoteNote, attrs)
  end

  def create_note_note(attrs \\ %{}) do
    %NoteNote{}
    |> NoteNote.changeset(attrs)
    |> Repo.insert()
  end

  def delete_note_note(%NoteNote{} = note_note) do
    Repo.delete(note_note)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking note_image changes.
  """
  def change_note_image(%NoteImage{} = note_image, attrs \\ %{}) do
    NoteImage.update_changeset(note_image, attrs)
  end
end
