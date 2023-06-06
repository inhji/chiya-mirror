defmodule ChiyaWeb.TokenHTML do
  use ChiyaWeb, :html

  embed_templates "token_html/*"

  @doc """
  Renders a token form.
  """
  attr :changeset, Ecto.Changeset, required: true
  attr :action, :string, required: true

  def token_form(assigns)
end
