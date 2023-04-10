defmodule ChiyaWeb.PageHTML do
  use ChiyaWeb, :html_public

  embed_templates "page_html/*"

  def tag_list([]), do: "No Tags"
  def tag_list(tags), do: Enum.map_join(tags, ", ", fn t -> t.name end)
end
