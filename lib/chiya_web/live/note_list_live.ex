defmodule ChiyaWeb.NoteListLive do
  use ChiyaWeb, :live_view

  @impl true
  def mount(_params, __session, socket) do
    {:ok, {notes, meta}} = Chiya.Notes.list_admin_notes(%{})
    {:ok, socket |> assign(%{notes: notes, meta: meta})}
  end

  @impl true
  def handle_params(params, _uri, socket) do
    case Chiya.Notes.list_admin_notes(params) do
      {:ok, {notes, meta}} ->
        {:noreply, socket |> assign(%{notes: notes, meta: meta})}

      {:error, data} ->
        IO.inspect(data)
        {:noreply, socket}
    end
  end

  @impl true
  def handle_event("update-filter", params, socket) do
    params = Map.delete(params, "_target")
    {:noreply, push_patch(socket, to: ~p"/admin/notes?#{params}")}
  end

  @impl true
  def render(assigns) do
    ~H"""
    <.header>
      <.icon name="hero-document-text" /> Notes
      <:subtitle>Notes are the content, the heart of your site.</:subtitle>
      <:actions>
        <.link href={~p"/admin/notes/new"}>
          <.button><.icon name="hero-plus-small" /> New Note</.button>
        </.link>
        <.link href={~p"/admin/notes/import"}>
          <.button><.icon name="hero-arrow-down-tray" /> Import Note</.button>
        </.link>
      </:actions>
    </.header>

    <section>
      <.filter_form fields={[name: [op: :ilike_and]]} meta={@meta} id="user-filter-form" />
    </section>

    <section class="flex flex-col gap-3 mt-6">
      <%= for note <- @notes do %>
        <article class="bg-slate-100 dark:bg-slate-800 text-slate-900 dark:text-slate-100 p-3 rounded">
          <header>
            <h2 class="text-xl leading-normal">
              <a href={"/admin/notes/#{note.id}"}><%= note.name %></a>
            </h2>
          </header>
          <footer class="flex gap-3 text-sm ">
            <span>Updated <%= from_now(note.updated_at) %></span>
            <span>Published <%= from_now(note.published_at) %></span>
          </footer>
        </article>
      <% end %>
    </section>

    <Flop.Phoenix.pagination meta={@meta} path={~p"/admin/notes"} />
    """
  end
end
