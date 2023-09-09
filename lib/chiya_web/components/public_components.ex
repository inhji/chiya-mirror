defmodule ChiyaWeb.PublicComponents do
  use Phoenix.Component

  use Phoenix.VerifiedRoutes,
    endpoint: ChiyaWeb.Endpoint,
    router: ChiyaWeb.Router,
    statics: ChiyaWeb.static_paths()

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
  Renders a horizontal line
  """
  def line(assigns),
    do: ~H"""
    <hr class="my-6 border-theme-base/20" />
    """

  @doc """
  Renders a note-header with title.
  """
  attr :class, :string, default: nil
  attr :class_title, :string, default: nil
  attr :class_subtitle, :string, default: nil

  slot :subtitle, required: false

  def header(assigns) do
    ~H"""
    <header class={[@class]}>
      <h1 class={["text-3xl leading-10 font-bold text-theme-base1", @class_title]}>
        <%= render_slot(@inner_block) %>
      </h1>
      <p
        :if={@subtitle != []}
        class={["mt-4 leading-7 text-theme-base", @class_subtitle]}
      >
        <%= render_slot(@subtitle) %>
      </p>
    </header>
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

  defp main_images(note),
    do: Enum.filter(note.images, fn image -> image.featured end)
end
