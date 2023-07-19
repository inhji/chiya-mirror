defmodule ChiyaWeb.Indie.Micropub do
  require Logger

  alias ChiyaWeb.Indie.Properties, as: Props
  alias ChiyaWeb.Indie.Token

  def create_note(type, properties) do
    settings = Chiya.Site.get_settings()
    channel_id = settings.micropub_channel_id

    with {:ok, note_attrs} <- get_attrs(type, properties, channel_id),
         {:ok, note} <- Chiya.Notes.create_note(note_attrs) do
      create_photos(note, properties)
      Logger.info("Note created!")

      {:ok, :created, Chiya.Notes.Note.note_url(note)}
    else
      error ->
        Logger.error("Error occurred while creating note from micropub:")
        Logger.error(inspect(error))

        {:error, :invalid_request}
    end
  end

  defp create_photos(note, properties) do
    properties
    |> Props.get_photos()
    |> Enum.with_index()
    |> Enum.each(fn {photo, index} ->
      featured = index == 0

      Chiya.Notes.create_note_image(%{
        note_id: note.id,
        path: photo.path,
        featured: featured
      })
    end)
  end

  def verify_token(access_token) do
    Enum.reduce_while(
      [
        &verify_app_token/1,
        &verify_micropub_token/1
      ],
      nil,
      fn fun, _result ->
        case fun.(access_token) do
          :ok -> {:halt, :ok}
          error -> {:cont, error}
        end
      end
    )
  end

  defp get_attrs(type, properties, channel_id) do
    {:ok, post_type} = Props.get_post_type(properties)
    Logger.info("Creating a #{type}/#{post_type}..")

    channel =
      if channel_id,
        do: Chiya.Channels.get_channel(channel_id),
        else: nil

    case post_type do
      :note -> get_note_attrs(properties, channel)
      :bookmark -> get_bookmark_attrs(properties, channel)
      _ -> {:error, :insufficient_scope}
    end
  end

  defp verify_micropub_token(access_token) do
    Token.verify(access_token, "create", get_hostname())
  end

  defp verify_app_token(access_token) do
    token = Chiya.Accounts.get_app_token("obsidian", "app")

    if not is_nil(token) do
      token_string =
        token.token
        |> :crypto.bytes_to_integer()
        |> to_string()

      if token_string == access_token do
        :ok
      else
        {:error, :insufficient_scope, "Could not verify app token"}
      end
    else
      {:error, :insufficient_scope, "Could not verify app token"}
    end
  end

  defp get_note_attrs(properties, channel) do
    attrs =
      properties
      |> get_base_attrs()
      |> get_channel(channel)

    {:ok, attrs}
  end

  defp get_bookmark_attrs(properties, channel) do
    url = Props.get_bookmarked_url(properties)

    attrs =
      properties
      |> get_base_attrs()
      |> get_channel(channel)
      |> Map.put_new(:url, url)
      |> Map.put_new(:kind, :bookmark)

    {:ok, attrs}
  end

  defp get_base_attrs(properties) do
    content = Props.get_content(properties)
    name = Props.get_title(properties) || Chiya.Notes.Note.note_title(content)
    tags = Props.get_tags(properties) |> Enum.join(",")

    published_at =
      if Props.is_published?(properties),
        do: NaiveDateTime.local_now(),
        else: nil

    attrs = %{
      content: content,
      name: name,
      tags_string: tags,
      published_at: published_at
    }

    attrs
  end

  def get_channel(attrs, channel) do
    if channel,
      do: Map.put(attrs, :channels, [channel]),
      else: attrs
  end

  defp get_hostname(),
    do: URI.parse(ChiyaWeb.Endpoint.url()).host
end
