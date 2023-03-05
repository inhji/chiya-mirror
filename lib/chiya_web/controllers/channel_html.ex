defmodule ChiyaWeb.ChannelHTML do
  use ChiyaWeb, :html

  embed_templates "channel_html/*"

  @doc """
  Renders a channel form.
  """
  attr :changeset, Ecto.Changeset, required: true
  attr :action, :string, required: true

  def channel_form(assigns)
end
