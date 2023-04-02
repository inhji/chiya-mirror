defmodule Chiya.Notes.NoteSlug do
  use EctoAutoslugField.Slug, from: :name, to: :slug
end
