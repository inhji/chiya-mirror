defmodule ChiyaWeb.NoteShowLive do
  use ChiyaWeb, :live_view

  alias Chiya.Notes

  @impl true
  def render(assigns) do
    ~H"""
    <.header>
      Note <%= @note.id %>
      <:subtitle>This is a note record from your database.</:subtitle>
      <:actions>
        <.link href={~p"/admin/notes/#{@note}/edit"}>
          <.button>Edit note</.button>
        </.link>
      </:actions>
    </.header>

    <.list>
      <:item title="Name"><%= @note.name %></:item>
      <:item title="Content"><%= @note.content %></:item>
      <:item title="Slug"><%= @note.slug %></:item>
      <:item title="Published at"><%= @note.published_at %></:item>
      <:item title="Kind"><%= @note.kind %></:item>
      <:item title="Url"><%= @note.url %></:item>
      <%= for channel <- @note.channels do %>
      <:item title="Channel"><%= @channel.name %></:item>
      <% end %>
    </.list>

    <.line />

    <div class="flex flex-wrap gap-3">
      <%= for image <- @note.images do %>
        <article>
          <a href={"#image-#{image.id}"}><img
            class="rounded-lg w-28 "
            src={Chiya.Uploaders.NoteImage.url({image.path, image}, :thumb_dithered)}
          /></a>
          <p class="text-center text-xs text-zinc-700"><a href="">Delete image</a></p>

          <a href="#" class="lightbox" id={"image-#{image.id}"}>
            <span style={"background-image: url('#{Chiya.Uploaders.NoteImage.url({image.path, image}, :full_dithered)}')"}></span>
          </a>
        </article>
      <% end %>
    </div>

    <.line />

    <.header>
      Note Images
      <:subtitle>Add images here</:subtitle>
    </.header>

    <.simple_form
      for={@image_form}
      id="image_form"
      phx-submit="update_image"
      phx-change="validate_image"
      multipart={true}
    >
      <.live_upload upload={@uploads.note_images} />

      <:actions>
        <.button phx-disable-with="Changing...">Add Images</.button>
      </:actions>
    </.simple_form>

    <.back navigate={~p"/admin/notes"}>Back to notes</.back>
    """
  end

  @impl true
  def mount(%{"id" => note_id}, _session, socket) do
    image_changeset = Notes.change_note_image(%Chiya.Notes.NoteImage{})

    {:ok,
     socket
     |> assign(:note, Notes.get_note_preloaded!(note_id))
     |> assign(:uploaded_files, [])
     |> assign(:image_form, to_form(image_changeset))
     |> allow_upload(:note_images, accept: ~w(.jpg .jpeg .gif .png), max_entries: 100)}
  end

  def handle_event("validate_image", _params, socket) do
    {:noreply, socket}
  end

  @impl Phoenix.LiveView
  def handle_event("cancel-upload", %{"ref" => ref}, socket) do
    {:noreply, cancel_upload(socket, :note_images, ref)}
  end

  @impl Phoenix.LiveView
  def handle_event("update_image", _params, socket) do
    uploaded_files =
      consume_uploaded_entries(socket, :note_images, fn %{path: path}, _entry ->
        {:ok, _note_image} =
          Notes.create_note_image(%{
            path: path,
            note_id: socket.assigns.note.id
          })

        {:ok, path}
      end)

    {:noreply,
     socket
     |> update(:uploaded_files, &(&1 ++ uploaded_files))
     |> assign(:note, Notes.get_note_preloaded!(socket.assigns.note.id))}
  end
end
