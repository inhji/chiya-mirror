defmodule ChiyaWeb.References do
  @moduledoc """
  Finds and replaces references to entities in a string.

  A reference is an internal link like the following examples:

  * `[[sustainablity]]` -> A note named *Sustainability*
  * `[[a-long-unfitting-slug|A simple title]]` -> A note named *A long unfitting title*
  """

  @reference_regex ~r/\[\[?(?<id>[\d\w-]+)(?:\|(?<title>[\w\d\s'`äöüß]+))?\]\]/

  @doc """
  Returns a list of references in `string`.
  """
  def get_references(nil), do: []

  def get_references(string) do
    @reference_regex
    |> Regex.scan(string, capture: :all)
    |> Enum.map(&map_to_tuple/1)
  end

  @doc """
  Checks each reference returned from `get_references/1` and validates its existence.
  """
  def validate_references(references) do
    Enum.map(references, fn {placeholder, slug, custom_title} ->
      note = Chiya.Notes.get_note_by_slug_preloaded(slug)

      valid =
        case note do
          nil -> false
          _ -> true
        end

      # If a custom title was defined, use it, 
      # otherwise use the note's title
      title =
        cond do
          custom_title != slug ->
            custom_title

          valid ->
            note.name

          true ->
            slug
        end

      {placeholder, slug, title, valid}
    end)
  end

  @doc """
  Returns a list of slugs that are referenced in `string`, optionally filtering by `filter_type`.
  """
  def get_reference_ids(string) do
    string
    |> get_references()
    |> Enum.map(fn {_, note_slug, _} -> note_slug end)
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

  defp get_link(slug, title, valid) do
    "[#{title}](/note/#{slug})#{get_link_class(valid)}"
  end

  defp get_link_class(valid) do
    if valid, do: "{:.invalid}", else: ""
  end

  defp map_to_tuple([placeholder, note_slug]),
    do: {placeholder, note_slug, note_slug}

  defp map_to_tuple([placeholder, note_slug, title]),
    do: {placeholder, note_slug, title}
end
