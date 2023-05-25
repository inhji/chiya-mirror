defmodule ChiyaWeb.Indie.MicropubHandler do
  @impl true
  def handle_create(type, properties, access_token) do
    properties = handle_uploads(properties)
    params = %{type: type, properties: properties}
    # Chiya.Notes.create_note
    id = 0
    {:ok, :created, ""}
  end

  def handle_create(_, _, _), do: {:error, :insufficient_scope}

  defp handle_uploads(props) do
  end
end
