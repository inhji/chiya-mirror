defmodule ChiyaWeb.Outline do
  @outline_regex ~r/\#{1,6}\s.+/
  @heading_regex ~r/^(#+)\s(.+)$/

  def get(markdown) do
    headings =
      @outline_regex
      |> Regex.scan(markdown, capture: :all)

    Enum.chunk_by(headings, fn h -> nil end)
  end

  def level(heading) do
    Regex.scan(@heading_regex, heading)
    |> Enum.map(fn [_, level, heading] ->
      [level_from_string(level), heading]
    end)
  end

  defp level_from_string(string), do: String.length(string)
end
