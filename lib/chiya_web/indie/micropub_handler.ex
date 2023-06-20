defmodule ChiyaWeb.Indie.MicropubHandler do
  @behaviour PlugMicropub.HandlerBehaviour
  require Logger

  alias ChiyaWeb.Indie.Properties, as: Props
  alias ChiyaWeb.Indie.Token

  @default_properties [
    "name",
    "content",
    "published_at",
    "slug",
    "channels",
    "tags"
  ]

  @impl true
  def handle_create(type, properties, access_token) do
    Logger.info("Handle create")
    Logger.info("Properties: #{inspect(properties)}")
    Logger.info("Type: #{type}")

    settings = Chiya.Site.get_settings()
    micropub_channel_id = settings.micropub_channel_id

    with :ok <- verify_token(access_token),
         {:ok, post_type} <- Props.get_post_type(properties),
         {:ok, note_attrs} <- get_attrs(type, post_type, properties, micropub_channel_id),
         {:ok, note} <- Chiya.Notes.create_note(note_attrs) do
      Logger.info("Note created!")
      {:ok, :created, Chiya.Notes.Note.note_url(note)}
    else
      error ->
        Logger.error("Error occurred while creating note from micropub:")
        Logger.error(inspect(error))

        {:error, :invalid_request}
    end
  end

  @impl true
  def handle_update(_, _, _, _, _) do
    {:error, :insufficient_scope}
  end

  @impl true
  def handle_delete(_url, _access_token) do
    {:error, :insufficient_scope}
  end

  @impl true
  def handle_undelete(_url, _access_token) do
    {:error, :insufficient_scope}
  end

  @impl true
  def handle_media(_files, _access_token) do
    {:error, :insufficient_scope}
  end

  @impl true
  def handle_source_query(url, filter_properties, access_token) do
    filter_properties =
      if Enum.empty?(filter_properties),
        do: @default_properties,
        else: filter_properties

    with :ok <- verify_token(access_token),
         {:ok, slug} <- Chiya.Notes.Note.note_slug(url),
         note <- Chiya.Notes.get_public_note_by_slug_preloaded!(slug) do
      filtered_note =
        Map.filter(note, fn {key, _val} ->
          Enum.member?(filter_properties, to_string(key))
        end)

      {:ok, filtered_note}
    else
      _ -> {:error, :insufficient_scope}
    end
  end

  @impl true
  def handle_config_query(access_token) do
    case verify_token(access_token) do
      :ok ->
        channels = Chiya.Channels.list_channels()

        {:ok,
         %{
           "destination" => [],
           "post-types" => [
             %{
               "type" => "note",
               "name" => "Note"
             }
           ],
           "channels" =>
             Enum.map(channels, fn c ->
               %{
                 "uid" => c.slug,
                 "name" => c.name
               }
             end)
         }}

      _ ->
        {:error, :insufficient_scope}
    end
  end

  @impl true
  def handle_syndicate_to_query(access_token) do
    case verify_token(access_token) do
      :ok -> {:ok, %{"syndicate-to" => []}}
      _ -> {:error, :insufficient_scope}
    end
  end

  @impl true
  def handle_category_query(access_token) do
    case verify_token(access_token) do
      :ok ->
        tags = Enum.map(Chiya.Tags.list_tags(), fn t -> t.name end)
        {:ok, %{"categories" => tags}}

      _ ->
        {:error, :insufficient_scope}
    end
  end

  defp verify_token(access_token) do
    Enum.reduce_while([&verify_app_token/1, &verify_micropub_token/1], nil, fn fun, _result ->
      case fun.(access_token) do
        :ok -> {:halt, :ok}
        error -> {:cont, error}
      end
    end)
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

  defp get_attrs(type, post_type, properties, default_channel_id) do
    Logger.info("Creating a #{type}/#{post_type}..")

    channel = Chiya.Channels.get_channel(default_channel_id)

    case post_type do
      :note -> get_note_attrs(properties, channel)
      _ -> {:error, :insufficient_scope}
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
