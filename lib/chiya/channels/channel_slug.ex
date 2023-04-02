defmodule Chiya.Channels.ChannelSlug do
  use EctoAutoslugField.Slug, from: :name, to: :slug
end
