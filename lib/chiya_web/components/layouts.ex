defmodule ChiyaWeb.Layouts do
  use ChiyaWeb, :html

  import ChiyaWeb.PublicComponents, only: [divider: 1, site_header: 1]

  embed_templates "layouts/*"
end
