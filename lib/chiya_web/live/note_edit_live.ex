defmodule ChiyaWeb.NoteEditLive do
  use ChiyaWeb, :live_view

  def render(assigns) do
    ~H"""
    <.header>
      <:actions>
        <.link href={~p"/admin/notes/#{@note.id}"}>
          <.button><.icon name="hero-arrow-left" /> Back to Note</.button>
        </.link>
      </:actions>
    </.header>

    <.simple_form for={@note_form} id="note_form" phx-change="validate_note" phx-submit="update_note">
      <header>
        <.input
          field={@note_form[:name]}
          type="text"
          class="border-none dark:border-none text-2xl dark:text-2xl"
        />

        <.input field={@note_form[:slug]} type="text" class="bg-gray-200 dark:bg-gray-900 font-mono" />
      </header>

      <section class="grid grid-cols-5 gap-6">
        <section class="col-span-5 md:col-span-3">
          <.input
            field={@note_form[:content]}
            type="textarea"
            label="Content"
            rows="20"
            class="font-mono"
          />
        </section>

        <section class="col-span-5 md:col-span-2 flex flex-col gap-6">
          <.input field={@note_form[:published_at]} type="datetime-local" label="Published at" />
          <.input
            field={@note_form[:kind]}
            type="select"
            label="Kind"
            prompt="Choose a value"
            options={Ecto.Enum.values(Chiya.Notes.Note, :kind)}
          />
          <.input field={@note_form[:url]} type="text" label="Url" />
          <.input
            field={@note_form[:tags_string]}
            type="text"
            label="Tags"
            value={tags_to_string(@note.tags)}
          />
          <.input
            field={@note_form[:channels]}
            type="select"
            label="Channel"
            multiple={true}
            options={@channels}
            value={@selected_channels}
          />
        </section>
      </section>

      <:actions>
        <.button>Save Note</.button>
      </:actions>
    </.simple_form>
    """
  end

  def mount(%{"id" => id}, _session, socket) do
    note = Chiya.Notes.get_note_preloaded!(id)
    changeset = Chiya.Notes.change_note(note)
    selected_channels = Enum.map(note.channels, fn c -> c.id end)

    {:ok,
     socket
     |> assign(%{
       note_form: to_form(changeset),
       note: note,
       action: ~p"/admin/notes/#{note}",
       channels: to_channel_options(),
       selected_channels: selected_channels
     })}
  end

  def handle_event("validate_note", params, socket) do
    %{"note" => note_params} = params

    note_form =
      socket.assigns.note
      |> Chiya.Notes.change_note(note_params)
      |> Map.put(:action, :validate)
      |> to_form()

    {:noreply, socket |> assign(:note_form, note_form)}
  end

  def handle_event("update_note", params, socket) do
    %{"note" => note_params} = params
    note_params = from_channel_ids(note_params)
    note = socket.assigns.note

    case Chiya.Notes.update_note(note, note_params) do
      {:ok, note} ->
        {:noreply,
         socket
         |> put_flash(:info, "Note updated successfully.")
         |> redirect(to: ~p"/admin/notes/#{note}")}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign(socket, :note_form, to_form(Map.put(changeset, :action, :update)))}
    end
  end

  def tags_to_string(tags), do: Enum.map_join(tags, ", ", fn t -> t.name end)

  defp from_channel_ids(note_params) do
    selected_ids = Enum.map(note_params["channels"] || [], &String.to_integer/1)

    selected_channels =
      Chiya.Channels.list_channels()
      |> Enum.filter(fn c -> Enum.member?(selected_ids, c.id) end)

    Map.put(note_params, "channels", selected_channels)
  end

  defp to_channel_options(items \\ nil),
    do:
      Enum.map(items || Chiya.Channels.list_channels(), fn c ->
        {Chiya.Channels.Channel.icon(c) <> " " <> c.name, c.id}
      end)
end
