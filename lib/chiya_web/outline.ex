defmodule ChiyaWeb.Outline do
  @outline_regex ~r/\#{1,6}\s.+/
  @heading_regex ~r/^(#+)\s(.+)$/

  def get(markdown) do
    @outline_regex
    |> Regex.scan(markdown, capture: :all)
    |> List.flatten()
    |> Enum.map(&into_map/1)
    |> into_tree([])
  end

  defp level_from_string(string), do: String.length(string)

  defp into_map(heading) do
    [[_, level, heading]] = Regex.scan(@heading_regex, heading)
    %{level: level_from_string(level), text: heading, children: []}
  end

  defp into_tree([], result), do: result

  defp into_tree([head | tail], result) do
    level = head.level

    # Split the remaining items (tail) at the next
    # same level element as the current (head)
    # The first list will be the children of the head,
    # the second list will be the new list
    {children, new_list} =
      Enum.split_while(tail, fn heading ->
        level < heading.level
      end)

    # add the children to the current item
    head = Map.put(head, :children, children)

    # call again with new list and current item 
    # added to result
    into_tree(new_list, result ++ [head])
  end
end
