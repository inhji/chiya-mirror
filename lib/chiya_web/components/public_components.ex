defmodule ChiyaWeb.PublicComponents do
  use Phoenix.Component

  use Phoenix.VerifiedRoutes,
    endpoint: ChiyaWeb.Endpoint,
    router: ChiyaWeb.Router,
    statics: ChiyaWeb.static_paths()

  import ChiyaWeb.Format
  import ChiyaWeb.Markdown, only: [render: 1]
  import Phoenix.HTML, only: [raw: 1]

  @doc """
  Renders a [Hero Icon](https://heroicons.com).

  Hero icons come in three styles – outline, solid, and mini.
  By default, the outline style is used, but solid an mini may
  be applied by using the `-solid` and `-mini` suffix.

  You can customize the size and colors of the icons by setting
  width, height, and background color classes.

  Icons are extracted from your `priv/hero_icons` directory and bundled
  within your compiled app.css by the plugin in your `assets/tailwind.config.js`.

  ## Examples

      <.icon name="hero-cake" />
      <.icon name="hero-cake-solid" />
      <.icon name="hero-cake-mini" />
      <.icon name="hero-bolt" class="bg-blue-500 w-10 h-10" />
  """
  attr :name, :string, required: true
  attr :class, :string, default: nil

  def icon(%{name: "hero-" <> _} = assigns) do
    ~H"""
    <span class={[@name, @class]} />
    """
  end

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
        note_list_gallery(assigns)

      :microblog ->
        note_list_microblog(assigns)

      _ ->
        note_list_headers(assigns)
    end
  end

  def note_list_headers(assigns) do
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

  attr :note, :map, required: true

  def note_list_microblog(assigns) do
    ~H"""
    <section class="note-list microblog | mt-6 text-theme-base">
      <%= for note <- assigns.notes do %>
        <article class="mt-4 first:mt-0">
          <.featured_images note={note} />

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
  end

  def note_list_gallery(assigns) do
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
  end

  def featured_images(assigns) do
    images = main_images(assigns.note)

    case Enum.count(images) do
      0 ->
        ~H"""
        <figure />
        """

      1 ->
        assigns = assign(assigns, :image, List.first(images))

        ~H"""
        <figure class="mb-4">
          <img
            src={ChiyaWeb.Helpers.image_url(assigns.image, :full)}
            class="rounded"
            title={assigns.image.content}
          />
        </figure>
        """

      2 ->
        assigns =
          assigns
          |> assign(:first, Enum.at(images, 0))
          |> assign(:second, Enum.at(images, 1))

        ~H"""
        <figure class="flex gap-1">
          <img
            src={ChiyaWeb.Helpers.image_url(assigns.first, :thumb)}
            class="rounded-l flex-1 w-full"
            title={assigns.first.content}
          />
          <img
            src={ChiyaWeb.Helpers.image_url(assigns.second, :thumb)}
            class="rounded-r flex-1 w-full"
            title={assigns.second.content}
          />
        </figure>
        """

        3 ->
          assigns =
            assigns
            |> assign(:first, Enum.at(images, 0))
            |> assign(:second, Enum.at(images, 1))
            |> assign(:third, Enum.at(images, 2))

          ~H"""
          <figure class="flex gap-1">
            <img
              src={ChiyaWeb.Helpers.image_url(assigns.first, :thumb)}
              class="flex-1 w-full rounded-l"
              title={assigns.first.content}
            />
            <img
              src={ChiyaWeb.Helpers.image_url(assigns.second, :thumb)}
              class="flex-1 w-full"
              title={assigns.second.content}
            />
            <img
              src={ChiyaWeb.Helpers.image_url(assigns.third, :thumb)}
              class="flex-1 w-full rounded-r"
              title={assigns.third.content}
            />
          </figure>
          """
    end
  end

  defp gallery_name(note), do: "gallery-#{note.id}"

  defp main_images(note),
    do: Enum.filter(note.images, fn image -> image.featured end)
end
