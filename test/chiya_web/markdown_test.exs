defmodule ChiyaWeb.MarkdownTest do
  use Chiya.DataCase

  alias ChiyaWeb.Markdown

  describe "render/1" do
    test "renders simple markdown" do
      html = Markdown.render("# Title")
      assert html =~ "id=\"title\""
      assert html =~ "Title"
      assert html =~ "</h1>"
    end

    test "renders a link to a note" do
      html = Markdown.render("[[foo]]")
      assert html =~ "/note/foo"
    end

    test "renders a link to a note with custom title" do
      html = Markdown.render("[[foo|MyFoo]]")
      assert html =~ "/note/foo"
      assert html =~ "MyFoo"
    end

    test "renders a link to a not existing note with custom class" do
      html = Markdown.render("[[foo]]")
      assert html =~ "/note/foo"
      assert html =~ "class=\"invalid\""
    end
  end
end
