defmodule Chiya.Notes.References do
  @moduledoc """
  Finds and replaces references to entities in a string.

  A reference is an internal link like the following examples:

  * `[[sustainablity]]` -> A note named *Sustainability*
  * `[[tag:video-games]]` -> A tag named *Video Games*
  * `[[list:blog]]` -> A list named *Blog*
  * `[[a-long-unfitting-title|A simple title]]` -> A note named *A long unfitting title*
  """

  require Logger

  use Phoenix.VerifiedRoutes,
    endpoint: ChiyaWeb.Endpoint,
    router: ChiyaWeb.Router,
    statics: ChiyaWeb.static_paths()

  @reference_regex ~r/\[\[(?<id>[\d\w-]+)(?:\|(?<title>[\w\d\s'`äöüß]+))?\]\]/

  @doc """
  Returns a list of references in `string`.
  """
  def get_references(nil), do: []
  def get_references(""), do: []

  def get_references(string) do
    @reference_regex
    |> Regex.scan(string, capture: :all)
    |> Enum.map(&map_to_tuple/1)
  end

  @doc """
  Checks each reference returned from `get_references/1` and validates its existence.
  """
  def validate_references(references) do
    Enum.map(references, fn {placeholder, type, slug, custom_title} ->
      {note, valid} =
        case Chiya.Notes.get_note_by_slug_preloaded(slug) do
          nil -> {nil, false}
          note -> {note, true}
        end

      # If a custom title was defined, use it, 
      # otherwise use the notes title
      title =
        if(slug == custom_title,
          do: note.name,
          else: custom_title
        )

      {placeholder, type, slug, title, valid}
    end)
  end

  @doc """
  Returns a list of slugs that are referenced in `string`, optionally filtering by `filter_type`.
  """
  def get_reference_ids(string) do
    string
    |> get_references()
    |> Enum.map(fn {_, note_slug, _} = _ref -> note_slug end)
  end

  @doc """
  Finds and replaces references with the matching url in `string`.
  """
  def replace_references(string) do
    string
    |> get_references()
    |> validate_references()
    |> Enum.reduce(string, fn {placeholder, slug, title, valid}, s ->
      String.replace(s, placeholder, get_link(slug, title, valid))
    end)
  end

  def update_references({:ok, note}, attrs) do
    note = Chiya.Notes.preload_note(note)

    new_reference_slugs = get_reference_ids(attrs["content"])
    Logger.info("New references")
    Logger.info(inspect(new_reference_slugs))

    old_reference_slugs = Enum.map(note.links_from, fn n -> n.slug end)
    Logger.info("Old references")
    Logger.info(inspect(old_reference_slugs))

    references_to_add = new_reference_slugs -- old_reference_slugs
    Logger.info("References to add: #{Enum.count(references_to_add)}")
    Logger.info(inspect(references_to_add))

    references_to_remove = old_reference_slugs -- new_reference_slugs
    Logger.info("References to remove: #{Enum.count(references_to_remove)}")
    Logger.info(inspect(references_to_remove))

    add_note_links(note, references_to_add)
    remove_note_links(note, references_to_remove)

    {:ok, note}
  end

  def update_references(error, _attrs), do: error

  defp add_note_links(origin_note, slugs) do
    Enum.each(slugs, fn slug ->
      case Chiya.Notes.get_note_by_slug_preloaded(slug) do
        nil ->
          Logger.warn("Reference to '#{slug}' could not be resolved")

        note ->
          add_note_link(slug, origin_note, note)
      end
    end)
  end

  defp add_note_link(slug, origin_note, linked_note) do
    attrs = get_attrs(origin_note.id, linked_note.id)

    case Chiya.Notes.create_note_note(attrs) do
      {:ok, _note_note} ->
        Logger.info("Reference to '#{slug}' created")

      {:error, changelog} ->
        Logger.warn("Reference was not added.")
        Logger.error(inspect(changelog))
    end
  end

  defp remove_note_links(origin_note, slugs) do
    Enum.each(slugs, fn slug ->
      linked_note = Chiya.Notes.get_note_by_slug_preloaded!(slug)
      attrs = get_attrs(origin_note.id, linked_note.id)
      note_note = Chiya.Notes.get_note_note(attrs)

      if note_note do
        case Chiya.Notes.delete_note_note(note_note) do
          {:ok, _note_note} ->
            Logger.info("Reference to '#{slug}' deleted")

          error ->
            Logger.warn(error)
        end
      else
        Logger.debug("Note '#{slug}' does not exist anymore.")
      end
    end)
  end

  defp get_attrs(origin_id, linked_id),
    do: %{
      source_id: origin_id,
      target_id: linked_id
    }

  defp get_link(slug, title, valid),
    do: "[#{title}](#{~p"/note/#{slug}"})#{get_link_class(valid)}"

  defp get_link_class(false), do: "{:.invalid}"
  defp get_link_class(_), do: ""

  defp map_to_tuple([placeholder, note_slug]),
    do: {placeholder, note_slug, note_slug}

  defp map_to_tuple([placeholder, note_slug, title]),
    do: {placeholder, note_slug, title}
end
