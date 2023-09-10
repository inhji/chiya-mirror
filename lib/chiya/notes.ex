defmodule Chiya.Notes do
  @moduledoc """
  The Notes context.
  """

  import Ecto.Query, warn: false
  alias Chiya.Repo
  alias Chiya.Notes.{Note, NoteImage, NoteImageTemp, NoteNote, NoteTag, NoteComment}

  @preloads [
    :channels,
    :images,
    :links_from,
    :links_to,
    tags: [:notes],
    comments:
      from(c in NoteComment,
        order_by: [
          desc: :approved_at,
          desc: :inserted_at
        ]
      )
  ]
  def note_preloads(), do: @preloads

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

  def list_admin_notes(params) do
    q =
      Note
      |> order_by([n], desc: n.updated_at, desc: n.published_at)

    Chiya.Flop.validate_and_run(q, params, for: Chiya.Notes.Note)
  end

  def list_home_notes(channel, params) do
    q =
      list_notes_by_channel_query(channel)
      |> where([n], not is_nil(n.published_at))
      |> order_by([n], desc: n.updated_at, desc: n.published_at)
      |> preload(^@preloads)

    Chiya.Flop.validate_and_run(q, params, for: Chiya.Notes.Note)
  end

  def list_apply_notes(regex) do
    Note
    |> where([n], fragment("? ~ ?", n.name, ^regex))
    |> Repo.all()
  end

  def list_notes_by_channel(%Chiya.Channels.Channel{} = channel) do
    list_notes_by_channel_query(channel)
    |> order_by([n], desc: n.updated_at, desc: n.published_at)
    |> Repo.all()
    |> Repo.preload(@preloads)
  end

  def list_notes_by_channel_published(%Chiya.Channels.Channel{} = channel, count \\ 10) do
    list_notes_by_channel_query(channel)
    |> order_by([n], desc: n.published_at)
    |> where([n], not is_nil(n.published_at))
    |> limit(^count)
    |> Repo.all()
    |> Repo.preload(@preloads)
  end

  def list_notes_by_channel_updated(%Chiya.Channels.Channel{} = channel, count \\ 10) do
    list_notes_by_channel_query(channel)
    |> order_by([n], desc: n.published_at)
    |> where([n], not is_nil(n.published_at))
    |> limit(^count)
    |> Repo.all()
    |> Repo.preload(@preloads)
  end

  defp list_notes_by_channel_query(%Chiya.Channels.Channel{} = channel) do
    Note
    |> join(:inner, [n], c in assoc(n, :channels))
    |> where([n, c], c.id == ^channel.id)
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
  def get_note_preloaded!(id),
    do:
      Note
      |> Repo.get!(id)
      |> preload_note()

  @doc """
  Gets a single note by its slug and preloads it.

  Raises `Ecto.NoResultsError` if the Note does not exist.

  ## Examples

      iex> get_note_preloaded!(123)
      %Note{}

      iex> get_note_preloaded!(456)
      ** (Ecto.NoResultsError)

  """
  def get_note_by_slug_preloaded!(slug),
    do:
      Note
      |> Repo.get_by!(slug: slug)
      |> preload_note()

  @doc """
  Gets a single note by its slug and preloads it.

  Returns nil if the Note does not exist.

  ## Examples

      iex> get_note_preloaded!(123)
      %Note{}

      iex> get_note_preloaded!(456)
      nil

  """
  def get_note_by_slug_preloaded(slug),
    do:
      Note
      |> Repo.get_by(slug: slug)
      |> preload_note()

  def get_public_note_by_slug_preloaded(slug),
    do:
      Note
      |> where([n], not is_nil(n.published_at))
      |> Repo.get_by(slug: slug)
      |> preload_note()

  def get_public_note_by_slug_preloaded!(slug),
    do:
      Note
      |> where([n], not is_nil(n.published_at))
      |> Repo.get_by!(slug: slug)
      |> preload_note()

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
    |> Chiya.Tags.TagUpdater.update_tags(attrs)
    |> Chiya.Notes.References.update_references(attrs)
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
    |> Chiya.Tags.TagUpdater.update_tags(attrs)
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

  def publish_note(%Note{} = note, published_at) do
    {1, nil} =
      Note
      |> where([n], n.id == ^note.id)
      |> Repo.update_all(set: [published_at: published_at])

    {:ok, note}
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
  Returns an `%Ecto.Changeset{}` for tracking note_image changes.
  """
  def change_note_image(%NoteImage{} = note_image, attrs \\ %{}) do
    NoteImage.update_changeset(note_image, attrs)
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

  def create_note_image_temp(attrs \\ %{}) do
    %NoteImageTemp{}
    |> NoteImageTemp.changeset(attrs)
    |> Repo.insert()
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

  def get_note_tag!(attrs \\ %{}) do
    Repo.get_by!(NoteTag, attrs)
  end

  def create_note_tag(attrs \\ %{}) do
    %NoteTag{}
    |> NoteTag.changeset(attrs)
    |> Repo.insert()
  end

  def delete_note_tag(%NoteTag{} = note_tag) do
    Repo.delete(note_tag)
  end

  def list_note_comments() do
    NoteComment
    |> order_by(:inserted_at)
    |> Repo.all()
    |> Repo.preload(:note)
  end

  def get_note_comment!(id) do
    Repo.get!(NoteComment, id) |> Repo.preload(:note)
  end

  def create_note_comment(attrs \\ %{}) do
    %NoteComment{}
    |> NoteComment.changeset(attrs)
    |> Repo.insert()
  end

  def delete_note_comment(%NoteComment{} = note_comment) do
    Repo.delete(note_comment)
  end

  def change_note_comment(%NoteComment{} = note_comment, attrs \\ %{}) do
    NoteComment.changeset(note_comment, attrs)
  end
end
