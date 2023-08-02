defmodule ChiyaWeb.Indie.Micropub do
  require Logger

  alias ChiyaWeb.Indie.Properties, as: Props
  alias ChiyaWeb.Indie.Token

  def create_note(type, properties) do
    settings = Chiya.Site.get_settings()

    with {:ok, note_attrs} <- get_create_attrs(type, properties, settings),
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

  def find_note(note_url) do
    slug = Chiya.Notes.Note.note_slug(note_url)
    note = Chiya.Notes.get_note_by_slug_preloaded(slug)

    if is_nil(note) do
      {:error, :invalid_request}
    else
      {:ok, note}
    end
  end

  def update_note(note, replace, add, delete) do
    with {:ok, note_attrs} <- get_update_attrs(replace, add, delete),
         {:ok, note} <- Chiya.Notes.update_note(note, note_attrs) do
      Logger.info("Note updated!")
      {:ok, note}
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

  defp get_create_attrs(type, properties, settings) do
    {:ok, post_type} = Props.get_post_type(properties)
    Logger.info("Creating a #{type}/#{post_type}..")

    case post_type do
      :note -> get_note_attrs(properties, settings.micropub_channel_id)
      :bookmark -> get_bookmark_attrs(properties, settings.bookmark_channel_id)
      _ -> {:error, :insufficient_scope}
    end
  end

  defp get_update_attrs(replace, add, _delete) do
    replace_attrs = put_update_attrs(replace)
    add_attrs = put_update_attrs(add)

    attrs =
      %{}
      |> Enum.into(replace_attrs)
      |> Enum.into(add_attrs)

    {:ok, attrs}
  end

  defp put_update_attrs(source) do
    name = Props.get_title(source)
    attrs = %{}

    attrs =
      if name do
        Map.put(attrs, :name, name)
      else
        attrs
      end

    content = Props.get_content(source)

    attrs =
      if content do
        Map.put(attrs, :content, content)
      else
        attrs
      end

    tags = Props.get_tags(source)

    attrs =
      if !Enum.empty?(tags) do
        tags_string = Enum.join(tags, ",")
        Map.put(attrs, :tags_string, tags_string)
      else
        attrs
      end

    attrs
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

  defp get_note_attrs(properties, channel_id) do
    attrs =
      properties
      |> get_base_attrs()
      |> get_channel(channel_id)

    {:ok, attrs}
  end

  defp get_bookmark_attrs(properties, channel_id) do
    url = Props.get_bookmarked_url(properties)

    attrs =
      properties
      |> get_base_attrs()
      |> get_channel(channel_id)
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

  def get_channel(attrs, channel_id) do
    if channel_id,
      do: Map.put(attrs, :channels, [Chiya.Channels.get_channel(channel_id)]),
      else: attrs
  end

  defp get_hostname(),
    do: URI.parse(ChiyaWeb.Endpoint.url()).host
end
