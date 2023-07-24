defmodule ChiyaWeb.Indie.MicropubHandler do
  @behaviour PlugMicropub.HandlerBehaviour
  require Logger

  use Phoenix.VerifiedRoutes,
    endpoint: ChiyaWeb.Endpoint,
    router: ChiyaWeb.Router

  alias ChiyaWeb.Indie.Micropub

  @default_properties [
    "name",
    "content",
    "published_at",
    "slug",
    "channels",
    "tags"
  ]

  @post_types [
    %{
      "type" => "note",
      "name" => "Note"
    },
    %{
      "type" => "bookmark",
      "name" => "Bookmark"
    }
  ]

  @impl true
  def handle_create(type, properties, access_token) do
    Logger.info("Handle create")
    Logger.info("Properties: #{inspect(properties)}")
    Logger.info("Type: #{type}")

    case Micropub.verify_token(access_token) do
      :ok -> Micropub.create_note(type, properties)
      _ -> {:error, :invalid_request}
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
  def handle_media(file, access_token) do
    with :ok <- Micropub.verify_token(access_token),
         {:ok, image} <- Chiya.Notes.create_note_image_temp(%{path: file.path}) do
      url = ChiyaWeb.Uploaders.NoteImageTemp.url({image.path, image}, :original)
      {:ok, url}
    else
      _ ->
        {:error, :insufficient_scope}
    end
  end

  @impl true
  def handle_source_query(url, filter_properties, access_token) do
    filter_properties =
      if Enum.empty?(filter_properties),
        do: @default_properties,
        else: filter_properties

    with :ok <- Micropub.verify_token(access_token),
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
    case Micropub.verify_token(access_token) do
      :ok ->
        channels = Chiya.Channels.list_channels()

        config = %{
          "media-endpoint" => url(~p"/indie/micropub/media"),
          "destination" => [],
          "post-types" => @post_types,
          "channels" =>
            Enum.map(channels, fn c ->
              %{
                "uid" => c.slug,
                "name" => c.name
              }
            end)
        }

        {:ok, config}

      _ ->
        {:error, :insufficient_scope}
    end
  end

  @impl true
  def handle_syndicate_to_query(access_token) do
    case Micropub.verify_token(access_token) do
      :ok -> {:ok, %{"syndicate-to" => []}}
      _ -> {:error, :insufficient_scope}
    end
  end

  @impl true
  def handle_category_query(access_token) do
    case Micropub.verify_token(access_token) do
      :ok ->
        tags = Enum.map(Chiya.Tags.list_tags(), fn t -> t.name end)
        {:ok, %{"categories" => tags}}

      _ ->
        {:error, :insufficient_scope}
    end
  end
end
