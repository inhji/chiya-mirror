defmodule ChiyaWeb.IdentityHTML do
  use ChiyaWeb, :html

  embed_templates "identity_html/*"

  @doc """
  Renders a identity form.
  """
  attr :changeset, Ecto.Changeset, required: true
  attr :action, :string, required: true

  def identity_form(assigns)
end
