defmodule ChiyaWeb.Markdown do
  @moduledoc """
  Module used for rendering markdown. 

  Rendering also collects and replaces internal [references](`Mirage.References`) to other entities like Lists and Tags.
  """

  import Ecto.Changeset, only: [get_change: 2, put_change: 3]

  defp options() do
    %Earmark.Options{
      code_class_prefix: "lang- language-",
      footnotes: true,
      breaks: true,
      escape: false,
      registered_processors: processors()
    }
  end

  @doc """
  Renders markdown with Earmark.
  """
  def render(markdown) do
    markdown
    |> ChiyaWeb.References.replace_references()
    |> Earmark.as_html!(options())
  end

  @doc """
  Renders markdown to HTML inside a changeset if markdown changed.
  Markdown field and HTML field can be configured.
  """
  def maybe_render(changeset, markdown_field, html_field) do
    if markdown = get_change(changeset, markdown_field) do
      html = render(markdown)
      put_change(changeset, html_field, html)
    else
      changeset
    end
  end

  def processors() do
    heading = fn
      {_, _, [content], _} = n when is_binary(content) ->
        slug = Slugger.slugify_downcase(content)
        Earmark.AstTools.merge_atts_in_node(n, id: slug)

      node ->
        node
    end

    [
      Earmark.TagSpecificProcessors.new([
        {"h1", heading},
        {"h2", heading},
        {"h3", heading},
        {"h4", heading},
        {"h5", heading},
        {"h6", heading}
      ])
    ]
  end
end
