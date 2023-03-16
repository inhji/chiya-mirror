defmodule ChiyaWeb.Layouts do
  use ChiyaWeb, :html

  embed_templates "layouts/*"

  @doc """
  Defines which themes are light and which are dark themes.
  This influences the prose styles in app.css. 
  """
  def theme_variant(:default), do: "light"
  def theme_variant(:roguelight), do: "dark"
end
