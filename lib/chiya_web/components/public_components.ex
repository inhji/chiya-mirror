defmodule ChiyaWeb.PublicComponents do
  use Phoenix.Component

  use Phoenix.VerifiedRoutes,
    endpoint: ChiyaWeb.Endpoint,
    router: ChiyaWeb.Router,
    statics: ChiyaWeb.static_paths()

  import ChiyaWeb.Format
  import ChiyaWeb.Markdown, only: [render: 1]
  import Phoenix.HTML, only: [raw: 1]

  import ChiyaWeb.DarkModeToggle

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

  attr :user, :map, required: true

  def site_header(assigns) do
    ~H"""
    <nav class="mx-auto max-w-2xl">
      <ul class="flex gap-3">
        <li>
          <a href="/" class="button">
            <.icon name="hero-home" />
          </a>
        </li>
        <li>
          <a href="/about" class="button">
            <svg
              xmlns="http://www.w3.org/2000/svg"
              width="16"
              height="16"
              fill="currentColor"
              class="bi bi-umbrella inline"
              viewBox="0 0 16 16"
            >
              <path d="M8 0a.5.5 0 0 1 .5.5v.514C12.625 1.238 16 4.22 16 8c0 0 0 .5-.5.5-.149 0-.352-.145-.352-.145l-.004-.004-.025-.023a3.484 3.484 0 0 0-.555-.394A3.166 3.166 0 0 0 13 7.5c-.638 0-1.178.213-1.564.434a3.484 3.484 0 0 0-.555.394l-.025.023-.003.003s-.204.146-.353.146-.352-.145-.352-.145l-.004-.004-.025-.023a3.484 3.484 0 0 0-.555-.394 3.3 3.3 0 0 0-1.064-.39V13.5H8h.5v.039l-.005.083a2.958 2.958 0 0 1-.298 1.102 2.257 2.257 0 0 1-.763.88C7.06 15.851 6.587 16 6 16s-1.061-.148-1.434-.396a2.255 2.255 0 0 1-.763-.88 2.958 2.958 0 0 1-.302-1.185v-.025l-.001-.009v-.003s0-.002.5-.002h-.5V13a.5.5 0 0 1 1 0v.506l.003.044a1.958 1.958 0 0 0 .195.726c.095.191.23.367.423.495.19.127.466.229.879.229s.689-.102.879-.229c.193-.128.328-.304.424-.495a1.958 1.958 0 0 0 .197-.77V7.544a3.3 3.3 0 0 0-1.064.39 3.482 3.482 0 0 0-.58.417l-.004.004S5.65 8.5 5.5 8.5c-.149 0-.352-.145-.352-.145l-.004-.004a3.482 3.482 0 0 0-.58-.417A3.166 3.166 0 0 0 3 7.5c-.638 0-1.177.213-1.564.434a3.482 3.482 0 0 0-.58.417l-.004.004S.65 8.5.5 8.5C0 8.5 0 8 0 8c0-3.78 3.375-6.762 7.5-6.986V.5A.5.5 0 0 1 8 0zM6.577 2.123c-2.833.5-4.99 2.458-5.474 4.854A4.124 4.124 0 0 1 3 6.5c.806 0 1.48.25 1.962.511a9.706 9.706 0 0 1 .344-2.358c.242-.868.64-1.765 1.271-2.53zm-.615 4.93A4.16 4.16 0 0 1 8 6.5a4.16 4.16 0 0 1 2.038.553 8.688 8.688 0 0 0-.307-2.13C9.434 3.858 8.898 2.83 8 2.117c-.898.712-1.434 1.74-1.731 2.804a8.687 8.687 0 0 0-.307 2.131zm3.46-4.93c.631.765 1.03 1.662 1.272 2.53.233.833.328 1.66.344 2.358A4.14 4.14 0 0 1 13 6.5c.77 0 1.42.23 1.897.477-.484-2.396-2.641-4.355-5.474-4.854z" />
            </svg>
            <span class="hidden sm:inline-block">About</span>
          </a>
        </li>
        <li>
          <a href="/wiki" class="button">
            <svg
              xmlns="http://www.w3.org/2000/svg"
              width="16"
              height="16"
              fill="currentColor"
              class="bi bi-journals inline"
              viewBox="0 0 16 16"
            >
              <path d="M5 0h8a2 2 0 0 1 2 2v10a2 2 0 0 1-2 2 2 2 0 0 1-2 2H3a2 2 0 0 1-2-2h1a1 1 0 0 0 1 1h8a1 1 0 0 0 1-1V4a1 1 0 0 0-1-1H3a1 1 0 0 0-1 1H1a2 2 0 0 1 2-2h8a2 2 0 0 1 2 2v9a1 1 0 0 0 1-1V2a1 1 0 0 0-1-1H5a1 1 0 0 0-1 1H3a2 2 0 0 1 2-2z" />
              <path d="M1 6v-.5a.5.5 0 0 1 1 0V6h.5a.5.5 0 0 1 0 1h-2a.5.5 0 0 1 0-1H1zm0 3v-.5a.5.5 0 0 1 1 0V9h.5a.5.5 0 0 1 0 1h-2a.5.5 0 0 1 0-1H1zm0 2.5v.5H.5a.5.5 0 0 0 0 1h2a.5.5 0 0 0 0-1H2v-.5a.5.5 0 0 0-1 0z" />
            </svg>
            <span class="hidden sm:inline">Wiki</span>
          </a>
        </li>
        <li>
          <a href="/bookmarks" class="button">
            <svg
              xmlns="http://www.w3.org/2000/svg"
              width="16"
              height="16"
              fill="currentColor"
              class="bi bi-bookmark-fill inline"
              viewBox="0 0 16 16"
            >
              <path d="M2 2v13.5a.5.5 0 0 0 .74.439L8 13.069l5.26 2.87A.5.5 0 0 0 14 15.5V2a2 2 0 0 0-2-2H4a2 2 0 0 0-2 2z" />
            </svg>
            <span class="hidden sm:inline-block">Bookmarks</span>
          </a>
        </li>
        <li class="flex-1"></li>
        <%= if @user do %>
          <li>
            <a href="/admin" class="button">
              <.icon name="hero-beaker" />
            </a>
          </li>
        <% end %>
        <li>
          <.darkmode_toggle class="button" />
        </li>
      </ul>
    </nav>
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
        <figure class="images-1">
          <.featured_image image={assigns.image} size={:full} class="rounded-lg" />
        </figure>
        """

      2 ->
        assigns =
          assigns
          |> assign(:first, Enum.at(images, 0))
          |> assign(:second, Enum.at(images, 1))

        ~H"""
        <figure class="images-2 | flex gap-1">
          <.featured_image image={assigns.first} size={:full} class="rounded-l flex-1 w-full" />
          <.featured_image image={assigns.second} size={:full} class="rounded-r flex-1 w-full" />
        </figure>
        """

      3 ->
        assigns =
          assigns
          |> assign(:first, Enum.at(images, 0))
          |> assign(:second, Enum.at(images, 1))
          |> assign(:third, Enum.at(images, 2))

        ~H"""
        <figure class="images-3 | flex gap-1">
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
        <figure class="images-4 | flex gap-1 flex-col">
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
