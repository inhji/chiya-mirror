defmodule ChiyaWeb.OutlineTest do
  use Chiya.SimpleCase

  alias ChiyaWeb.Outline

  describe "extract_outline/1" do
    test "extracts headlines from markdown" do
      markdown =
        "# Heading\nsome paragraph\n## Sub Heading\nsome text\n## Second Sub Heading\nmore text\n# Second Heading"

      result = [
        %{
          level: 1,
          text: "Heading",
          children: [
            %{level: 2, text: "Sub Heading", children: []},
            %{level: 2, text: "Second Sub Heading", children: []}
          ]
        },
        %{level: 1, text: "Second Heading", children: []}
      ]

      assert result == Outline.get(markdown)
    end
  end

  test "extracts headlines from markdown 2" do
    markdown = "## Second Level"

    result = [
      %{level: 2, text: "Second Level", children: []}
    ]

    assert result == Outline.get(markdown)
  end
end
