defmodule ChiyaWeb.Layouts do
  use ChiyaWeb, :html

  import ChiyaWeb.PublicComponents, only: [divider: 1]

  embed_templates "layouts/*"
end
