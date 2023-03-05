defmodule ChiyaWeb.NoteHTML do
  use ChiyaWeb, :html

  embed_templates "note_html/*"

  @doc """
  Renders a note form.
  """
  attr :changeset, Ecto.Changeset, required: true
  attr :action, :string, required: true
  attr :channels, :list, required: true

  def note_form(assigns)

  def selected_channels(changeset), do: Enum.map(changeset.data.channels, fn c -> c.id end)
end
