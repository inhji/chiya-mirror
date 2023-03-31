defmodule ChiyaWeb.AdminComponents do
  use Phoenix.Component

  use Phoenix.VerifiedRoutes,
    endpoint: ChiyaWeb.Endpoint,
    router: ChiyaWeb.Router,
    statics: ChiyaWeb.static_paths()

  import ChiyaWeb.CoreComponents

  @doc """
  Renders a horizontal line
  """
  def line(assigns) do
    ~H"""
    <hr class="my-6 dark:border-gray-700" />
    """
  end

  @doc """
  Renders a UI for uploading files
  """

  attr :upload, :map, required: true
  attr :cancel_upload, :string, default: "cancel-upload"

  def live_upload(assigns) do
    ~H"""
    <div>
      <.live_file_input upload={@upload} class="dark:text-gray-300" />

      <section phx-drop-target={@upload.ref}>
        <%= for entry <- @upload.entries do %>
          <article class="upload-entry">
            <figure>
              <.live_img_preview entry={entry} />
              <figcaption><%= entry.client_name %></figcaption>
            </figure>

            <%!-- entry.progress will update automatically for in-flight entries --%>
            <progress value={entry.progress} max="100"><%= entry.progress %>%</progress>

            <%!-- a regular click event whose handler will invoke Phoenix.LiveView.cancel_upload/3 --%>
            <button
              type="button"
              phx-click="cancel-upload"
              phx-value-ref={entry.ref}
              aria-label="cancel"
            >
              &times;
            </button>

            <%!-- Phoenix.Component.upload_errors/2 returns a list of error atoms --%>
            <%= for err <- upload_errors(@upload, entry) do %>
              <p class="alert alert-danger"><%= upload_error_to_string(err) %></p>
            <% end %>
          </article>
        <% end %>

        <%!-- Phoenix.Component.upload_errors/1 returns a list of error atoms --%>
        <%= for err <- upload_errors(@upload) do %>
          <p class="alert alert-danger"><%= upload_error_to_string(err) %></p>
        <% end %>
      </section>
    </div>
    """
  end

  @doc """
  Renders the admin menu bar
  """

  attr :current_user, :map, required: true

  def admin_bar(assigns) do
    ~H"""
    <ul class="relative z-10 flex items-center gap-4 py-1 px-4 sm:px-6 lg:px-8 bg-black">
      <li>
        <.link
          href={~p"/"}
          class="flex gap-3 text-sm leading-6 text-gray-100 font-semibold hover:text-gray-300"
        >
          <span>Chiya</span>
          <p class="rounded-full bg-theme-primary/10 px-2 text-[0.8125rem] font-medium leading-6 text-theme-primary">
            v<%= Application.spec(:chiya, :vsn) %>
          </p>
        </.link>
      </li>
      <li class="flex-1"></li>
      <%= if @current_user do %>
        <li>
          <.link
            href="#"
            id="dark-mode-toggle"
            class="text-xs leading-6 text-gray-100 font-semibold hover:text-gray-300"
          >
            <.icon name="hero-sun-mini" class="h-4 w-4" />
          </.link>
        </li>
        <li>
          <.link
            href={~p"/user"}
            class="text-xs leading-6 text-gray-100 font-semibold hover:text-gray-300"
          >
            Profile
          </.link>
        </li>
        <li>
          <.link
            href={~p"/admin"}
            class="text-xs leading-6 text-gray-100 font-semibold hover:text-gray-300"
          >
            Admin
          </.link>
        </li>
        <li>
          <.link
            href={~p"/user/log_out"}
            method="delete"
            class="text-xs leading-6 text-gray-100 font-semibold hover:text-gray-300"
          >
            Log out
          </.link>
        </li>
      <% else %>
        <li>
          <.link
            href="#"
            id="dark-mode-toggle"
            class="text-xs leading-6 text-gray-100 font-semibold hover:text-gray-300"
          >
            <.icon name="hero-sun-mini" class="h-4 w-4" />
          </.link>
        </li>
        <li>
          <.link
            href={~p"/user/log_in"}
            class="text-xs leading-6 text-gray-100 font-semibold hover:text-gray-300"
          >
            Log in
          </.link>
        </li>
      <% end %>
    </ul>
    """
  end

  defp upload_error_to_string(:too_large), do: "Too large"
  defp upload_error_to_string(:too_many_files), do: "You have selected too many files"
  defp upload_error_to_string(:not_accepted), do: "You have selected an unacceptable file type"
end
