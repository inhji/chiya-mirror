defmodule ChiyaWeb.OutlineRenderer do
  import Phoenix.HTML, only: [safe_to_string: 1]
  import Phoenix.HTML.Tag, only: [content_tag: 3, content_tag: 2]

  def render_outline(content) do
    children =
      content
      |> ChiyaWeb.Outline.get()
      |> Enum.map(&do_render_outline/1)

    root = content_tag(:ul, do: children)

    safe_to_string(root)
  end

  def has_outline?(content) do
    outline_empty =
      content
      |> ChiyaWeb.Outline.get()
      |> Enum.empty?()

    !outline_empty
  end

  def do_render_outline(%{text: text, children: children, level: _level}) do
    slug = Slugger.slugify_downcase(text)
    list_item = content_tag(:li, do: content_tag(:a, text, href: "##{slug}"))

    if Enum.empty?(children) do
      [list_item]
    else
      [
        list_item,
        content_tag(:ul, do: Enum.map(children, &do_render_outline/1))
      ]
    end
  end
end
