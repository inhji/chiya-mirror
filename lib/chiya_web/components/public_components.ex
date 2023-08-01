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
  attr :class, :string, default: "text-theme-primary"

  def dot(assigns),
    do: ~H"""
    <span class={["font-bold", @class]}>·</span>
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
    <div class="flex items-center my-8 text-theme-primary before:flex-1 after:flex-1 before:content-[''] after:content-[''] before:p-[0.5px] after:p-[0.5px] before:bg-theme-base/25 after:bg-theme-base/25 w-full mx-auto last:hidden">
      <%= assigns.text %>
    </div>
    """
  end

  attr :note, :map, required: true
  attr :class_tag, :string, default: ""
  attr :linked, :boolean, default: true

  def tags(assigns) do
    ~H"""
    <span class="inline-flex flex-row gap-1">
      <%= for tag <- @note.tags do %>
        <%= if assigns.linked do %>
        <a class={["p-category", @class_tag]} href={~p"/tagged-with/#{tag.slug}"}>
          <%= tag.name %>
        </a>
        <% else %>
        <span class={["p-category", @class_tag]}>
          <%= tag.name %>
        </span>
        <% end %>
        <.dot class="text-theme-base/50 last:hidden" />
      <% end %>
    </span>
    """
  end

  @doc """
  Renders a note-header with title.
  """
  attr :class, :string, default: nil
  attr :class_title, :string, default: nil
  attr :class_subtitle, :string, default: nil

  slot :subtitle, required: false

  def header(assigns) do
    ~H"""
    <header class={["p-8 rounded bg-theme-background1", @class]}>
      <h1 class={["text-3xl leading-10 text-theme-base", @class_title]}>
        <%= render_slot(@inner_block) %>
      </h1>
      <p
        :if={@subtitle != []}
        class={["mt-4 leading-7 font-semibold text-theme-base/75", @class_subtitle]}
      >
        <%= render_slot(@subtitle) %>
      </p>
    </header>
    """
  end

  attr :layout, :atom, default: :list
  attr :notes, :list, required: true
  attr :show_content, :boolean, default: true

  def note_list(assigns) do
    case assigns.layout do
      :gallery ->
        note_list_gallery(assigns)

      :microblog ->
        note_list_microblog(assigns)

      _ ->
        note_list_default(assigns)
    end
  end

  attr :notes, :list, required: true

  @doc """
  Default note list that renders a list of rounded boxes, 
  which show the note title and an excerpt of the content
  """
  def note_list_default(assigns) do
    ~H"""
    <section class="note-list default | sm:w-auto flex flex-col gap-3">
      <%= for note <- assigns.notes do %>
        <a
          href={~p"/note/#{note.slug}"}
          class="block rounded-lg px-6 py-4 border border-theme-background1 hover:bg-theme-background1 transition"
        >
          <header class="flex flex-row items-center gap-1">
            <span class="text-theme-primary text-lg font-semibold leading-8 flex-1">
              <%= note.name %>
            </span>
            <span class="text-theme-base/75 text-sm">
              <%= pretty_date(note.published_at) %>
            </span>
          </header>

          <%= if assigns.show_content do %>
            <p class="text-theme-base">
              <%= String.slice(note.content, 0..150) %>
            </p>
          <% end %>

          <%= if not Enum.empty?(note.tags) do %>
          <span class="inline-block">
            <.tags note={note} linked={false} />
          </span>
          <% end %>
        </a>
      <% end %>
    </section>
    """
  end

  attr :notes, :list, required: true

  def note_list_microblog(assigns) do
    ~H"""
    <section class="note-list microblog | mt-6 text-theme-base">
      <%= for note <- assigns.notes do %>
        <article class="mt-4 first:mt-0">
          <.featured_images note={note} />

          <header class="mt-4 text-lg">
            <%= if(note.kind == :bookmark) do %>
              <strong><%= note.name %></strong>
            <% end %>
          </header>

          <div class="prose prose-gruvbox mt-4">
            <%= raw(render(note.content)) %>
          </div>

          <footer class="mt-4">
            <a href={~p"/note/#{note.slug}"}>
              <time class="text-theme-base/75">
                <%= pretty_datetime(note.published_at) %>
              </time>
            </a>
            <%= if not Enum.empty?(note.tags) do %>
              <.dot />
              <.tags note={note} class_tag="text-theme-base/75" />
            <% end %>
          </footer>
        </article>

        <.divider />
      <% end %>
    </section>
    """
  end

  attr :notes, :list, required: true

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

  attr :note, :map, required: true

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
        <figure>
          <.featured_image image={assigns.image} size={:full} class="rounded-lg" />
        </figure>
        """

      2 ->
        assigns =
          assigns
          |> assign(:first, Enum.at(images, 0))
          |> assign(:second, Enum.at(images, 1))

        ~H"""
        <figure class="flex gap-1">
          <.featured_image image={assigns.first} size={:thumb} class="rounded-l flex-1 w-full" />
          <.featured_image image={assigns.second} size={:thumb} class="rounded-r flex-1 w-full" />
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
          <.featured_image image={assigns.first} size={:thumb} class="flex-1 w-full rounded-l" />
          <.featured_image image={assigns.second} size={:thumb} class="flex-1 w-full" />
          <.featured_image image={assigns.third} size={:thumb} class="flex-1 w-full rounded-r" />
        </figure>
        """

      _ ->
        assigns =
          assigns
          |> assign(:first, Enum.at(images, 0))
          |> assign(:second, Enum.at(images, 1))
          |> assign(:third, Enum.at(images, 2))
          |> assign(:fourth, Enum.at(images, 3))

        ~H"""
        <figure class="flex gap-1 flex-col">
          <section class="flex gap-1">
            <.featured_image image={assigns.first} size={:thumb} class="flex-1 w-full rounded-tl-lg" />
            <.featured_image image={assigns.second} size={:thumb} class="flex-1 w-full rounded-tr-lg" />
          </section>
          <section class="flex gap-1">
            <.featured_image image={assigns.third} size={:thumb} class="flex-1 w-full rounded-bl-lg" />
            <.featured_image image={assigns.fourth} size={:thumb} class="flex-1 w-full rounded-br-lg" />
          </section>
        </figure>
        """
    end
  end

  attr :image, :map, required: true
  attr :class, :string
  attr :size, :atom, default: :thumb

  defp featured_image(assigns) do
    ~H"""
    <img
      src={ChiyaWeb.Helpers.image_url(assigns.image, assigns.size)}
      class={assigns.class}
      title={assigns.image.content}
    />
    """
  end

  defp gallery_name(note), do: "gallery-#{note.id}"

  defp main_images(note),
    do: Enum.filter(note.images, fn image -> image.featured end)
end
