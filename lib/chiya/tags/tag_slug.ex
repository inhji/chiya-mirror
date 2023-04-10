defmodule Chiya.Tags.TagSlug do
  use EctoAutoslugField.Slug, from: :name, to: :slug
end
