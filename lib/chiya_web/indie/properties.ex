defmodule ChiyaWeb.Indie.Properties do
  def get_post_type(properties) do
    cond do
      Map.has_key?(properties, "like-of") ->
        {:ok, :like}

      Map.has_key?(properties, "bookmark-of") ->
        {:ok, :bookmark}

      Map.has_key?(properties, "content") ->
        {:ok, :note}

      true ->
        {:error, :unsupported_posttype}
    end
  end

  def get_tags(%{"category" => [""]} = _props), do: []
  def get_tags(%{"category" => tags} = _props), do: tags
  def get_tags(_props), do: []

  def get_title(%{"name" => [title]} = _props), do: title
  def get_title(_props), do: nil

  def get_content(%{"content" => [%{"html" => content_html}]} = _props), do: content_html
  def get_content(%{"content" => [content]} = _props), do: content
  def get_content(_props), do: nil

  def get_bookmarked_url(%{"bookmark-of" => [url]} = _props), do: url
  def get_bookmarked_url(_props), do: nil

  def get_reposted_url(%{"repost-of" => [url]} = _props), do: url
  def get_reposted_url(_props), do: nil

  def get_liked_url(%{"like-of" => [url]} = _props), do: url
  def get_liked_url(_props), do: nil

  def get_read_url(%{"read-of" => [url]} = _props), do: url
  def get_read_url(_props), do: nil

  def get_watched_url(%{"watch-of" => [url]} = _props), do: url
  def get_watched_url(_props), do: nil

  def get_listened_url(%{"listen-of" => [url]} = _props), do: url
  def get_listened_url(_props), do: nil

  def get_reply_to(%{"in-reply-to" => [reply_to]} = _props), do: reply_to
  def get_reply_to(_props), do: nil

  def is_published?(%{"post-status" => ["draft"]} = _props), do: false
  def is_published?(_props), do: true

  def get_photos(%{"photo" => photos} = _props), do: photos
  def get_photos(_props), do: []

  def get_syndication_targets(%{"mp-syndicate-to" => targets} = _props), do: targets
  def get_syndication_targets(_props), do: []

  def get_channel(%{"mp-channel" => [channel]} = _props), do: channel
  def get_channel(_props), do: nil

  def has_target?(%{"mp-syndicate-to" => targets} = _props, name),
    do: Enum.any?(targets, fn t -> t == name end)

  def has_target?(_props, _name), do: false
end
