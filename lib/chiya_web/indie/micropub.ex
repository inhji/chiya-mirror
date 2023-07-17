defmodule ChiyaWeb.Indie.Micropub do
  require Logger

  alias ChiyaWeb.Indie.Properties, as: Props
  alias ChiyaWeb.Indie.Token

  def create_note(type, properties, channel_id) do
    with {:ok, post_type} <- Props.get_post_type(properties),
         {:ok, note_attrs} <- get_attrs(type, post_type, properties, channel_id),
         {:ok, note} <- Chiya.Notes.create_note(note_attrs) do
      Logger.info("Note created!")

      # TODO: Make separate function for this
      properties
      |> Props.get_photos()
      |> Enum.map(fn photo ->
        Chiya.Notes.create_note_image(%{
          note_id: note.id,
          path: photo.path
        })
      end)
      |> Enum.each(fn result ->
        Logger.info("Photo created!")
        Logger.info(inspect(result))
      end)

      {:ok, :created, Chiya.Notes.Note.note_url(note)}
    else
      error ->
        Logger.error("Error occurred while creating note from micropub:")
        Logger.error(inspect(error))

        {:error, :invalid_request}
    end
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

  defp get_attrs(type, post_type, properties, default_channel_id) do
    Logger.info("Creating a #{type}/#{post_type}..")

    channel =
      if default_channel_id,
        do: Chiya.Channels.get_channel(default_channel_id),
        else: nil

    case post_type do
      :note -> get_note_attrs(properties, channel)
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

  defp get_note_attrs(p, default_channel) do
    content = Props.get_content(p)
    name = Props.get_title(p) || Chiya.Notes.Note.note_title(content)
    tags = Props.get_tags(p) |> Enum.join(",")

    published_at =
      if Props.is_published?(p),
        do: NaiveDateTime.local_now(),
        else: nil

    attrs = %{
      content: content,
      name: name,
      tags_string: tags,
      published_at: published_at
    }

    attrs =
      if default_channel,
        do: Map.put(attrs, :channel, default_channel),
        else: attrs

    {:ok, attrs}
  end

  defp get_hostname(),
    do: URI.parse(ChiyaWeb.Endpoint.url()).host
end
