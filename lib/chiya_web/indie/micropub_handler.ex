defmodule ChiyaWeb.Indie.MicropubHandler do
  require Logger


  @impl true
  def handle_create(type, properties, access_token) do
    with :ok <- ChiyaWeb.Indie.Token.verify(access_token, "create", get_hostname()),
         {:ok, note_attrs} <- note_attrs(type, properties),
         {:ok, note} <- Chiya.Notes.create_note(note_attrs) do
      # After token has been verified,
      # note attrs have been created,
      # we can create the note and return its url!
      {:ok, :created, Chiya.Notes.Note.note_url(note)}
    else
      error ->
        Logger.error("Error occurred while creating note from micropub:")
        dbg(error)

        {:error, :unhandled_error}
    end
  end

  def handle_create(_, _, _), do: {:error, :insufficient_scope}

  defp note_attrs(type, properties) do
  end

  defp handle_uploads(props) do
  end

  defp get_hostname(),
    do: URI.parse(ChiyaWeb.Endpoint.url()).host
end
