defmodule ChiyaWeb.PageHTML do
  use ChiyaWeb, :html_public
  import Phoenix.HTML.Tag, only: [content_tag: 3, content_tag: 2]
  import ChiyaWeb.Format, only: [pretty_datetime: 1, pretty_date: 1, datetime: 1]

  embed_templates "page_html/*"

  
  attr :notes, :list, required: true
  def note_list_default(assigns)

  def tag_list([]), do: "No Tags"
  def tag_list(tags), do: Enum.map_join(tags, ", ", fn t -> t.name end)

  def render_outline(note) do
    note.content
    |> ChiyaWeb.Outline.get()
    |> Enum.map(&do_render_outline/1)
    |> Enum.map(&safe_to_string/1)
  end

  def has_outline?(note) do
    outline_empty =
      note.content
      |> ChiyaWeb.Outline.get()
      |> Enum.empty?()

    !outline_empty
  end

  def do_render_outline(%{text: text, children: children, level: _level}) do
    slug = Slugger.slugify_downcase(text)

    content_tag(:ul, [class: "m-0"],
      do: [
        content_tag(:li, do: content_tag(:a, text, href: "##{slug}")),
        Enum.map(children, &do_render_outline/1)
      ]
    )
  end
end
