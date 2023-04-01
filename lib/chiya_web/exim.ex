defmodule ChiyaWeb.Exim do
  alias Chiya.Notes.Note

  defp create_frontmatter(%Note{name: title, channels: channels}) do
    channels_raw = Enum.map_join(channels, "], [", fn c -> "\"#{c.name}\"" end)
    "title: \"#{title}\"\ncategories: [#{channels_raw}]"
  end

  def export_note(%Note{content: content} = note) do
    "---\n#{create_frontmatter(note)}\n---\n#{content}"
  end
end
