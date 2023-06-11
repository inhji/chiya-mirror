defmodule ChiyaWeb.PublicComponents do
  use Phoenix.Component

  use Phoenix.VerifiedRoutes,
    endpoint: ChiyaWeb.Endpoint,
    router: ChiyaWeb.Router,
    statics: ChiyaWeb.static_paths()

  import ChiyaWeb.Format
  import ChiyaWeb.Markdown, only: [render: 1]
  import Phoenix.HTML, only: [raw: 1]
  import ChiyaWeb.CoreComponents

  @doc """
  Renders a middot as divider
  """
  def dot(assigns),
    do: ~H"""
    <span class="text-theme-primary font-bold">·</span>
    """

  @doc """
  Renders a horizontal line
  """
  def line(assigns),
    do: ~H"""
    <hr class="my-6 border-theme-base/20" />
    """

  attr :text, :string, default: "⌘"

  def divider(assigns) do
    ~H"""
    <div class="flex items-center my-8 text-theme-base/75 before:flex-1 after:flex-1 before:content-[''] after:content-[''] before:p-[0.5px] after:p-[0.5px] before:bg-theme-base/25 after:bg-theme-base/25 w-full mx-auto last:hidden">
      <%= assigns.text %>
    </div>
    """
  end

  @doc """
  Renders a note-header with title.
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
                    href={ChiyaWeb.Helpers.image_url(image, :full)}
                    class="lightbox | w-28"
                    data-gallery={gallery_name(note)}
                    data-description={ChiyaWeb.Markdown.render(image.content)}
                  >
                    <img src={ChiyaWeb.Helpers.image_url(image, :thumb)} loading="lazy" />
                  </a>
                <% end %>
              </section>
              <a
                href={~p"/note/#{note.slug}"}
                class="text-theme-secondary text-lg/10 font-semibold rounded-lg -mx-2 -my-0.5 px-2 py-0.5 hover:bg-theme-secondary/10 transition"
              >
                <%= note.name %>
                <span class="text-theme-base/75 text-sm">
                  <%= pretty_date(note.published_at) %>
                </span>
              </a>
            </article>

            <.line />
          <% end %>
        </section>
        """

      :microblog ->
        ~H"""
        <section class="note-list microblog | mt-6 text-theme-base">
          <%= for note <- assigns.notes do %>
            <article class="mt-4 first:mt-0">
              <% image = main_image(note) %>
              <%= if image do %>
                <figure class="mb-4">
                  <img
                    src={ChiyaWeb.Helpers.image_url(image, :full)}
                    class="rounded"
                    title={image.content}
                  />
                </figure>
              <% end %>

              <div class="prose prose-gruvbox">
                <%= raw(render(note.content)) %>
              </div>
              <footer class="mt-1">
                <time class="text-theme-base/75">
                  <%= pretty_datetime(note.published_at) %>
                </time>
                <.dot />
                <a href={~p"/note/#{note.slug}"} class="text-theme-base/75">Permalink</a>
                <%= if not Enum.empty?(note.images) do %>
                  <.dot />
                  <.icon name="hero-photo" />
                <% end %>
              </footer>
            </article>

            <.divider />
          <% end %>
        </section>
        """

      # default, show headings only
      _ ->
        ~H"""
        <section class="note-list default | mt-6 sm:w-auto flex flex-col gap-1.5">
          <%= for note <- assigns.notes do %>
            <a
              href={~p"/note/#{note.slug}"}
              class="rounded-lg -mx-2 -my-0.5 px-2 py-0.5 hover:bg-theme-secondary/10 transition"
            >
              <span class="text-theme-secondary text-lg font-semibold leading-8">
                <%= note.name %>
              </span>
              <span class="text-theme-base/75 text-sm"><%= pretty_date(note.published_at) %></span>
            </a>
          <% end %>
        </section>
        """
    end
  end

  def comment_form(assigns) do
    ~H"""
    <.simple_form
      :let={f}
      for={@changeset}
      action={~p"/note/#{assigns.note.slug}/comment"}
      class="bg-theme-background -m-3"
    >
      <.error :if={@changeset.action}>
        Oops, something went wrong! Please check the errors below.
      </.error>
      <.input
        field={f[:author_name]}
        type="text"
        placeholder="Name"
        class="bg-theme-background dark:bg-theme-background border-theme-base/20 dark:border-theme-base/20 text-theme-base dark:text-theme-base placeholder-theme-base/40 dark:placeholder-theme-base/60 dark:focus:border-theme-base/60 dark:focus:border-theme-base/60"
      />
      <.input
        field={f[:content]}
        type="textarea"
        placeholder="Content"
        rows="3"
        class="bg-theme-background dark:bg-theme-background border-theme-base/20 dark:border-theme-base/20 text-theme-base dark:text-theme-base placeholder-theme-base/60 dark:placeholder-theme-base/60 focus:border-theme-base/60 dark:focus:border-theme-base/60"
      />
      <.input field={f[:note_id]} type="hidden" />
      <:actions>
        <.button>Submit Comment</.button>
      </:actions>
    </.simple_form>
    """
  end

  def comment_list(assigns) do
    ~H"""
    <%= if not Enum.empty?(assigns.note.comments) do %>
      <.line />

      <h2 class="mb-6 text-theme-base"><%= Enum.count(assigns.note.comments) %> Comments</h2>

      <aside id="comments" class="flex flex-col gap-6">
        <%= for comment <- assigns.note.comments do %>
          <article class="text-theme-base bg-theme-base/10 p-1">
            <header class="flex flex-row justify-between">
              <strong class="text-theme-primary"><%= comment.author_name %></strong>
              <span class="text-theme-dim"><%= from_now(comment.inserted_at) %></span>
            </header>
            <p><%= comment.content %></p>
          </article>
        <% end %>
      </aside>
    <% else %>
      <.line />

      <h2 class="mb-6 text-theme-base">No comments yet.</h2>
    <% end %>
    """
  end

  defp gallery_name(note), do: "gallery-#{note.id}"

  defp main_image(note),
    do:
      note.images
      |> Enum.filter(fn image -> image.featured end)
      |> List.first()
end
