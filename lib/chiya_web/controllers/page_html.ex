defmodule ChiyaWeb.PageHTML do
  use ChiyaWeb, :html_public
  import ChiyaWeb.Format, only: [pretty_datetime: 1, pretty_date: 1]

  embed_templates "page_html/*"

  attr :notes, :list, required: true
  attr :layout, :atom, default: :default
  attr :show_content, :boolean, default: true
  def note_list(assigns)

  attr :notes, :list, required: true
  attr :show_content, :boolean, default: true
  def note_list_default(assigns)

  attr :notes, :list, required: true
  attr :show_content, :boolean, default: true
  def note_list_microblog(assigns)

  attr :notes, :list, required: true
  attr :show_content, :boolean, default: true
  def note_list_gallery(assigns)

  attr :note, :map, required: true
  attr :linked, :boolean, default: true
  def tag_list(assigns)

  def render_outline(note) do
    ChiyaWeb.OutlineRenderer.render_outline(note.content)
  end

  def has_outline?(note) do
    ChiyaWeb.OutlineRenderer.has_outline?(note.content)
  end

  def group_tags(notes) do
    Enum.reduce(notes, [], fn n, acc ->
      acc ++ n.tags
    end)
    |> Enum.uniq_by(fn t -> t.id end)
    |> Enum.sort_by(fn t -> t.slug end, :asc)
    |> Enum.group_by(
      fn n -> String.first(n.name) end,
      fn n -> n end
    )
  end
end
