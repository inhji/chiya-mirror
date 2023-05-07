defmodule ChiyaWeb.PublicComponents do
  use Phoenix.Component

  use Phoenix.VerifiedRoutes,
    endpoint: ChiyaWeb.Endpoint,
    router: ChiyaWeb.Router,
    statics: ChiyaWeb.static_paths()

  import ChiyaWeb.Format

  @doc """
  Renders a horizontal line
  """
  def line(assigns) do
    ~H"""
    <hr class="my-6 border-theme-base/20" />
    """
  end

  @doc """
  Renders a header with title.
  """
  attr :class, :string, default: nil
  attr :inline, :boolean, default: false

  slot :inner_block, required: true
  slot :subtitle
  slot :actions

  def header(assigns) do
    ~H"""
    <header class={[@actions != [] && "flex items-center justify-between gap-6", @class]}>
      <div>
        <h1 class="text-lg font-semibold leading-8 text-gray-800 dark:text-gray-200">
          <%= render_slot(@inner_block) %>
          <span :if={@inline} class="text-sm leading-6 font-normal text-gray-600 dark:text-gray-400">
            <%= render_slot(@subtitle) %>
          </span>
        </h1>
        <p
          :if={@subtitle != [] && @inline == false}
          class="mt-2 text-sm leading-6 text-gray-600 dark:text-gray-400"
        >
          <%= render_slot(@subtitle) %>
        </p>
      </div>
      <div class="flex-none"><%= render_slot(@actions) %></div>
    </header>
    """
  end

  attr :layout, :atom, default: :list
  attr :notes, :list, required: true

  def note_list(assigns) do
    case assigns.layout do
      :gallery ->
        ~H"""
        <section class="note-list gallery | mt-6">
          <%= for note <- assigns.notes do %>
            <article>
              <section class="flex flex-wrap justify-start gap-3">
                <%= for image <- note.images do %>
                  <a
                    href={ChiyaWeb.Uploaders.NoteImage.url({image.path, image}, :full_dithered)}
                    class="lightbox | w-28"
                    data-gallery={gallery_name(note)}
                    data-description={ChiyaWeb.Markdown.render(image.content)}
                  >
                    <img
                      src={ChiyaWeb.Uploaders.NoteImage.url({image.path, image}, :thumb_dithered)}
                      loading="lazy"
                    />
                  </a>
                <% end %>
              </section>
              <a
                href={~p"/#{note.slug}"}
                class="text-theme-primary text-lg/10 font-semibold rounded-lg -mx-2 -my-0.5 px-2 py-0.5 hover:bg-theme-primary/10 transition"
              >
                <%= note.name %>
                <span class="text-theme-muted font-normal text-sm">
                  <%= pretty_date(note.published_at) %>
                </span>
              </a>
            </article>

            <.line />
          <% end %>
        </section>
        """

      _ ->
        ~H"""
        <section class="default | mt-6 sm:w-auto flex flex-col gap-1.5">
          <%= for note <- assigns.notes do %>
            <a
              href={~p"/#{note.slug}"}
              class="rounded-lg -mx-2 -my-0.5 px-2 py-0.5 hover:bg-theme-primary/10 transition"
            >
              <span class="text-theme-primary text-lg font-semibold leading-8">
                <%= note.name %>
              </span>
              <span class="text-theme-base text-sm"><%= pretty_date(note.published_at) %></span>
            </a>
          <% end %>
        </section>
        """
    end
  end

  defp gallery_name(note), do: "gallery-#{note.id}"
end
