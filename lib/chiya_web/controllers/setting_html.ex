defmodule ChiyaWeb.SettingHTML do
  use ChiyaWeb, :html

  embed_templates "setting_html/*"

  @doc """
  Renders a setting form.
  """
  attr :changeset, Ecto.Changeset, required: true
  attr :action, :string, required: true
  attr :channels, :list, required: true

  def setting_form(assigns)
end
