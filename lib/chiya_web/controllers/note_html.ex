defmodule ChiyaWeb.NoteHTML do
  use ChiyaWeb, :html

  embed_templates("note_html/*")

  @doc """
  Renders a note form.
  """
  attr(:changeset, Ecto.Changeset, required: true)
  attr(:action, :string, required: true)
  attr(:channels, :list, required: true)
  attr(:tags, :list, required: true)
  attr(:selected_channels, :list, required: true)

  def note_form(assigns)

  def tags_to_string(tags), do: Enum.map_join(tags, ", ", fn t -> t.name end)
end
