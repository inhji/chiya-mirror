defmodule Chiya.Site.Setting do
  use Ecto.Schema
  import Ecto.Changeset

  schema "settings" do
    field :title, :string, default: "Title"
    field :subtitle, :string, default: "Subtitle"

    field :custom_css, :string, default: ""
    field :custom_html, :string, default: ""

    field :theme, Ecto.Enum, values: [:default]

    field :user_agent, :string, default: "Chiya/0.x +https://inhji.de"

    timestamps()
  end

  @doc false
  def changeset(setting, attrs) do
    setting
    |> cast(attrs, [:title, :subtitle, :theme, :user_agent, :custom_css, :custom_html])
    |> validate_required([:title, :subtitle, :theme, :user_agent])
  end
end
