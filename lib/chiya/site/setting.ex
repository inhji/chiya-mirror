defmodule Chiya.Site.Setting do
  use Ecto.Schema
  import Ecto.Changeset

  schema "settings" do
    field :title, :string, default: "Title"
    field :subtitle, :string, default: "Subtitle"

    field :custom_css, :string, default: ""
    field :custom_html, :string, default: ""

    field :theme, Ecto.Enum, values: [:default, :frame, :gruvbox], default: :default

    field :user_agent, :string, default: "Chiya/0.x +https://inhji.de"

    belongs_to :home_channel, Chiya.Channels.Channel
    belongs_to :default_channel, Chiya.Channels.Channel
    belongs_to :micropub_channel, Chiya.Channels.Channel
    belongs_to :wiki_channel, Chiya.Channels.Channel
    belongs_to :bookmark_channel, Chiya.Channels.Channel

    field :show_images_on_home, :boolean, default: true

    timestamps()
  end

  @doc false
  def changeset(setting, attrs) do
    setting
    |> cast(attrs, [
      :title,
      :subtitle,
      :theme,
      :user_agent,
      :custom_css,
      :custom_html,
      :home_channel_id,
      :default_channel_id,
      :micropub_channel_id,
      :wiki_channel_id,
      :bookmark_channel_id,
      :show_images_on_home
    ])
    |> validate_required([
      :title,
      :subtitle,
      :theme,
      :user_agent,
      :show_images_on_home
    ])
  end
end
