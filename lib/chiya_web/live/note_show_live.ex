defmodule ChiyaWeb.NoteShowLive do
  use ChiyaWeb, :live_view

  alias Chiya.Notes
  alias Chiya.Notes.NoteImage

  @impl true
  def render(assigns) do
    channels = Enum.map_join(assigns.note.channels, ", ", fn c -> c.name end)
    assigns = assign(assigns, :channels, channels)

    ~H"""
    <.header>
      Note <%= @note.id %>
      <:subtitle>This is a note record from your database.</:subtitle>
      <:actions>
        <.link href={~p"/admin/notes/#{@note}/edit"}>
          <.button>Edit note</.button>
        </.link>
        <.link href={~p"/n/#{@note.slug}"}>
          <.button>Preview</.button>
        </.link>
        <.link href={~p"/admin/notes/#{@note}/raw"}>
          <.button>Raw</.button>
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
      <:item title="Channels"><%= @channels %></:item>
    </.list>

    <.line />

    <%= if !Enum.empty?(@note.images) do %>
      <div class="flex flex-wrap gap-3" id="images">
        <%= for image <- @note.images do %>
          <article>
            <a href="#" phx-click={show_modal("image-edit-modal-#{image.id}")} phx-value-id={image.id}>
              <img
                class="rounded-lg border border-theme-dim w-28"
                src={ChiyaWeb.Uploaders.NoteImage.url({image.path, image}, :thumb_dithered)}
              />
            </a>

            <.modal id={"image-edit-modal-#{image.id}"}>
              <.simple_form
                :let={f}
                for={to_form(Notes.change_note_image(image))}
                id={"image-edit-form-#{image.id}"}
                phx-submit="update_edit_image"
                phx-change="validate_edit_image"
              >
                <.input field={f[:id]} type="hidden" value={image.id} />
                <.input field={f[:content]} type="textarea" label="Content" />
                <.input field={f[:featured]} type="checkbox" label="Featured" />

                <:actions>
                  <.button type="submit" phx-click={hide_modal("image-edit-modal-#{image.id}")}>
                    Save
                  </.button>
                  <.button
                    phx-click="delete_image"
                    phx-value-id={image.id}
                    data-confirm="Are you sure?"
                  >
                    Delete Image
                  </.button>
                </:actions>
              </.simple_form>
            </.modal>
          </article>
        <% end %>
      </div>

      <.line />
    <% end %>

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
    image_changeset = Notes.change_note_image(%NoteImage{})

    {:ok,
     socket
     |> assign(:note, Notes.get_note_preloaded!(note_id))
     |> assign(:uploaded_files, [])
     |> assign(:image_edit_form, to_form(image_changeset))
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

  def handle_event("validate_edit_image", assigns, socket) do
    {:noreply,
     socket
     |> assign(
       :image_edit_form,
       to_form(Notes.change_note_image(%NoteImage{}, assigns))
     )}
  end

  def handle_event("update_edit_image", %{"id" => id} = assigns, socket) do
    id
    |> Notes.get_note_image!()
    |> Notes.update_note_image(assigns)
    
    {:noreply, socket}
  end

  @impl Phoenix.LiveView
  def handle_event("delete_image", %{"id" => id}, socket) do
    :ok =
      Notes.get_note_image!(id)
      |> Notes.delete_note_image()

    {:noreply, assign(socket, :note, Notes.get_note_preloaded!(socket.assigns.note.id))}
  end
end
