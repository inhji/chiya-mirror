defmodule Chiya.Tags.TagUpdater do
  @moduledoc """
  Updates tags for a note like notes by adding new ones and removing old ones.
  """

  require Logger

  alias Chiya.{Notes, Tags}
  alias Chiya.Notes.Note

  @doc """
  Updates a tag for the given note.

  ## Examples

      iex> update_tags({:ok, note}, "foo,bar")
  """
  def update_tags({:ok, %Note{} = note}, attrs) do
    note
    |> Notes.preload_note()
    |> update_tags(attrs)

    {:ok, note}
  end

  def update_tags({:error, changeset}, _attrs) do
    {:error, changeset}
  end

  def update_tags(%Note{} = note, %{tags_string: new_tags} = attrs) when is_map(attrs) do
    update_tags(note, new_tags)
  end

  def update_tags(%Note{} = note, %{"tags_string" => new_tags} = attrs) when is_map(attrs) do
    update_tags(note, new_tags)
  end

  def update_tags(%Note{} = note, attrs) when is_map(attrs) do
    note
  end

  def update_tags(%Note{} = note, new_tags) when is_binary(new_tags) do
    update_tags(note, split_tags(new_tags))
  end

  def update_tags(%{tags: tags} = note, new_tags) when is_list(new_tags) do
    old_tags = Enum.map(tags, fn tag -> String.downcase(tag.slug) end)

    new_tags =
      Enum.map(new_tags, fn tag ->
        tag
        |> String.downcase()
        |> Slugger.slugify(45)
      end)

    Logger.info("Adding tags #{inspect(new_tags -- old_tags)}")
    Logger.info("Removing tags #{inspect(old_tags -- new_tags)}")

    note
    |> add_tags(new_tags -- old_tags)
    |> remove_tags(old_tags -- new_tags)
  end

  def add_tags(note, tags) do
    tags
    |> Enum.uniq()
    |> Enum.each(&add_tag(note, &1))

    note
  end

  defp split_tags(tags_string) when is_binary(tags_string) do
    tags_string
    |> String.split(",")
    |> Enum.map(&String.trim/1)
    |> Enum.filter(&(String.length(&1) > 0))
  end

  defp add_tag(%{id: note_id} = note, tag) when is_binary(tag) do
    slug = Slugger.slugify_downcase(tag)

    Logger.debug("Looking up tag [#{tag}] with slug [#{slug}]")

    {:ok, tag} =
      case Tags.get_tag_by_slug(slug) do
        nil ->
          Logger.debug("Tag [#{tag}] does not exist. Creating.")
          Tags.create_tag(%{name: tag})

        tag ->
          Logger.debug("Tag already exists. Returning.")
          {:ok, tag}
      end

    case note do
      %Note{} ->
        attrs = %{
          note_id: note_id,
          tag_id: tag.id
        }

        case Notes.create_note_tag(attrs) do
          {:ok, _note_tag} ->
            true

          {:error, changeset} ->
            Logger.warning(inspect(changeset))
            false
        end
    end
  end

  defp remove_tags(note, tags) do
    tags
    |> Enum.uniq()
    |> Enum.each(&remove_tag(note, &1))

    note
  end

  defp remove_tag(note, tag) do
    slug = Slugger.slugify_downcase(tag)

    if tag = Tags.get_tag_by_slug(slug) do
      case note do
        %Note{} ->
          attrs = %{tag_id: tag.id, note_id: note.id}
          note_tag = Notes.get_note_tag!(attrs)

          {:ok, _} = Notes.delete_note_tag(note_tag)
      end
    else
      Logger.warning("Tag with slug #{slug} was not removed.")
      nil
    end
  end
end
