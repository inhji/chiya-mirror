defmodule Chiya.NotesFixtures do
  @moduledoc """
  This module defines test helpers for creating
  entities via the `Chiya.Notes` context.
  """

  @doc """
  Generate a unique note slug.
  """
  def unique_note_slug, do: "some slug#{System.unique_integer([:positive])}"

  @doc """
  Generate a note.
  """
  def note_fixture(attrs \\ %{}) do
    {:ok, note} =
      attrs
      |> Enum.into(%{
        content: "some content",
        kind: "some kind",
        name: "some name",
        published_at: ~N[2023-03-04 16:22:00],
        slug: unique_note_slug(),
        url: "some url"
      })
      |> Chiya.Notes.create_note()

    note
  end
end
