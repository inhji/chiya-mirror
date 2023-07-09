defmodule ChiyaWeb.OutlineTest do
  use Chiya.SimpleCase

  alias ChiyaWeb.Outline

  describe "extract_outline/1" do
    test "extracts headlines from markdown" do
      markdown = "# Heading\nsome paragraph\n## Sub Heading\n# Second Heading"

      assert [{1, "Heading", [{2, "Sub Heading", []}]}, {1, "Second Heading", []}] =
               Outline.get(markdown)
    end
  end

  describe "outline_level/1" do
    test "extracts outline level" do
      assert {1, "Heading"} = Outline.level("# Heading")
    end
  end
end
