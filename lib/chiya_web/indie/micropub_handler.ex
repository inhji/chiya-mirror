defmodule ChiyaWeb.Indie.MicropubHandler do
  @behaviour PlugMicropub.HandlerBehaviour
  require Logger

  alias ChiyaWeb.Indie.Properties, as: Props
  alias ChiyaWeb.Indie.Token

  @impl true
  def handle_create(type, properties, access_token) do
    dbg(properties)

    with :ok <- Token.verify(access_token, "create", get_hostname()),
         {:ok, post_type} <- Props.get_post_type(properties),
         {:ok, note_attrs} <- note_attrs(type, post_type, properties),
         {:ok, note} <- Chiya.Notes.create_note(note_attrs) do
      {:ok, :created, Chiya.Notes.Note.note_url(note)} |> dbg()
    else
      error ->
        Logger.error("Error occurred while creating note from micropub:")
        dbg(error)

        {:error, :unhandled_error}
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
  def handle_source_query(_url, _filter_properties, _access_token) do
    {:error, :insufficient_scope}
  end

  @impl true
  def handle_media(_files, _access_token) do
    {:error, :insufficient_scope}
  end

  @impl true
  def handle_config_query(_access_token) do
    {:error, :insufficient_scope}
  end

  @impl true
  def handle_syndicate_to_query(_access_token) do
    {:error, :insufficient_scope}
  end

  defp note_attrs("h-entry", post_type, properties) do
    case post_type do
      :note -> do_note_attrs(properties)
      _ -> {:error, :insufficient_scope}
    end
  end

  defp note_attrs(_, _, _), do: {:error, :insufficient_scope}

  defp do_note_attrs(p) do
    content = Props.get_content(p)
    name = Props.get_title(p) || String.slice(content, 0..15)
    tags = Props.get_tags(p) |> Enum.join(",")

    {:ok,
     %{
       content: content,
       name: name,
       tags_string: tags
     }}
    |> dbg()
  end

  defp get_hostname(),
    do: URI.parse(ChiyaWeb.Endpoint.url()).host
end
