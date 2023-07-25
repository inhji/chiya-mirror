defmodule ChiyaWeb.NoteShowLive do
  use ChiyaWeb, :live_view

  alias Chiya.Notes
  alias Chiya.Notes.NoteImage
  import Phoenix.HTML.Tag

  @accepted_extensions ~w(.jpg .jpeg .gif .png .webp)

  @impl true
  def render(assigns) do
    ~H"""
    <.header>
      <%= @note.name %>
      <:actions>
        <.link href={~p"/admin/notes/#{@note}/edit"}>
          <.button><.icon name="hero-pencil" /> Edit</.button>
        </.link>
        <.link href={~p"/note/#{@note.slug}"}>
          <.button><.icon name="hero-eye" /> Preview</.button>
        </.link>
        <%= if is_nil(@note.published_at) do %>
          <.link href={~p"/admin/notes/#{@note}/publish"}>
            <.button><.icon name="hero-newspaper" /> Publish</.button>
          </.link>
        <% else %>
          <.link href={~p"/admin/notes/#{@note}/unpublish"}>
            <.button><.icon name="hero-newspaper" /> Un-Publish</.button>
          </.link>
        <% end %>
        <.link href={~p"/admin/notes/#{@note}/raw"}>
          <.button><.icon name="hero-code-bracket" /> Raw</.button>
        </.link>
        <.link href={~p"/admin/notes/#{@note}"} method="delete" data-confirm="Are you sure?">
          <.button><.icon name="hero-trash" /> Delete</.button>
        </.link>
      </:actions>
    </.header>

    <.list>
      <:item title="Published at">
        <%= pretty_date(@note.published_at) %> <span>(<%= from_now(@note.published_at) %>)</span>
      </:item>
      <:item title="Channels"><%= note_channels(@note.channels) %></:item>
      <:item title="Kind"><%= @note.kind %></:item>
      <:item title="Url"><%= @note.url %></:item>
      <:item title="Tags"><%= note_tags(@note.tags) %></:item>
      <:item title="Links outgoing"><%= note_links(@note.links_from) %></:item>
      <:item title="Links incoming"><%= note_links(@note.links_to) %></:item>
      <:item title="Embed">
        <pre class="p-1 bg-gray-100 text-black rounded select-all">[[<%= @note.slug %>]]</pre>
      </:item>
    </.list>

    <.line />

    <%= if !Enum.empty?(@note.images) do %>
      <div class="flex flex-wrap gap-3" id="images">
        <%= for image <- @note.images do %>
          <article>
            <a href={"/admin/notes/#{@note.id}/image/#{image.id}"}>
              <img
                class={[
                  "rounded-lg border border-theme-dim w-28 mb-3",
                  image.featured && "border-theme-primary"
                ]}
                src={ChiyaWeb.Uploaders.NoteImage.url({image.path, image}, :thumb_dithered)}
              />
            </a>
            <div class="flex justify-between">
              <.button phx-click="delete_image" phx-value-id={image.id} data-confirm="Are you sure?">
                <.icon name="hero-trash" />
              </.button>
              <.button phx-click="toggle_favorite" phx-value-id={image.id}>
                <.icon name="hero-star-solid" />
              </.button>
            </div>
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
    """
  end

  @impl true
  def mount(%{"id" => note_id}, _session, socket) do
    image_changeset = Notes.change_note_image(%NoteImage{})
    note = Notes.get_note_preloaded!(note_id)

    {:ok,
     socket
     |> assign(:note, note)
     |> assign(:uploaded_files, [])
     |> assign(:image_edit_form, to_form(image_changeset))
     |> assign(:image_form, to_form(image_changeset))
     |> assign(:page_title, note.name)
     |> allow_upload(:note_images,
       accept: @accepted_extensions,
       max_entries: 100
     )}
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

  @impl Phoenix.LiveView
  def handle_event("validate_edit_image", assigns, socket) do
    {:noreply,
     socket
     |> assign(
       :image_edit_form,
       to_form(Notes.change_note_image(%NoteImage{}, assigns))
     )}
  end

  @impl Phoenix.LiveView
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

  @impl Phoenix.LiveView
  def handle_event("toggle_favorite", %{"id" => id}, socket) do
    image = Notes.get_note_image!(id)
    Notes.update_note_image(image, %{featured: !image.featured})

    {:noreply, assign(socket, :note, Notes.get_note_preloaded!(socket.assigns.note.id))}
  end

  defp note_links(notes), do: content_tag(:ul, do: Enum.map(notes, &note_link/1))

  defp note_link(note) do
    content_tag(:li, do: content_tag(:a, note.name, href: Chiya.Notes.Note.note_path_admin(note)))
  end

  defp note_tags(tags), do: content_tag(:ul, do: Enum.map(tags, &note_tag/1))

  defp note_tag(tag),
    do: content_tag(:li, do: content_tag(:a, tag.name, href: ~p"/tagged-with/#{tag.slug}"))

  defp note_channels(channels), do: content_tag(:ul, do: Enum.map(channels, &note_channel/1))

  defp note_channel(channel),
    do:
      content_tag(:li, do: content_tag(:a, channel.name, href: ~p"/admin/channels/#{channel.id}"))
end
