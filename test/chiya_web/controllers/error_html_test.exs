defmodule ChiyaWeb.ErrorHTMLTest do
  use ChiyaWeb.ConnCase, async: true

  # Bring render_to_string/4 for testing custom views
  import Phoenix.Template

  test "renders 404.html" do
    assert render_to_string(ChiyaWeb.ErrorHTML, "404", "html", []) =~ "Not Found"
  end

  test "renders 500.html" do
    assert render_to_string(ChiyaWeb.ErrorHTML, "500", "html", []) =~ "Infernal Server Error"
  end
end
