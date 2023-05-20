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
              <figcaption class="dark:text-gray-100"><%= entry.client_name %></figcaption>
            </figure>

            <div class="flex">
              <%!-- entry.progress will update automatically for in-flight entries --%>
              <progress value={entry.progress} max="100" class="w-full">
                <%= entry.progress %>%
              </progress>

              <%!-- a regular click event whose handler will invoke Phoenix.LiveView.cancel_upload/3 --%>
              <button
                class="px-2 dark:text-white"
                type="button"
                phx-click="cancel-upload"
                phx-value-ref={entry.ref}
                aria-label="cancel"
              >
                &times;
              </button>
            </div>

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
  attr :settings, :map, required: true

  def admin_bar(assigns) do
    ~H"""
    <ul class="sticky top-0 backdrop-blur-sm z-10 flex items-center gap-4 py-3 px-4 sm:px-6 lg:px-8 bg-white/30 dark:bg-black/30">
      <li>
        <.link
          href={~p"/"}
          class="flex gap-3 text-sm leading-6 font-semibold text-gray-900 dark:text-gray-100 dark:hover:text-gray-300 hover:text-gray-700"
        >
          <%= @settings.title %>
        </.link>
      </li>
      <li class="flex-1"></li>
      <%= if @current_user do %>
        <li>
          <.link
            href={~p"/admin"}
            class="text-sm leading-6 text-gray-900 dark:text-gray-100 dark:hover:text-gray-300 hover:text-gray-700"
          >
            Admin
          </.link>
        </li>
        <li>
          <.link
            href={~p"/user/log_out"}
            method="delete"
            class="text-sm leading-6 text-gray-900 dark:text-gray-100 dark:hover:text-gray-300 hover:text-gray-700"
          >
            Log out
          </.link>
        </li>
      <% else %>
        <li>
          <.link
            href={~p"/user/log_in"}
            class="text-xs leading-6 text-gray-900 dark:text-gray-100 font-semibold dark:hover:text-gray-300 hover:text-gray-700"
          >
            Log in
          </.link>
        </li>
      <% end %>
      <li>
        <.link href="#" id="dark-mode-toggle" class="text-sm leading-6">
          <span class="inline dark:hidden bg-blue-900 p-1 rounded">🌙</span>
          <span class="hidden dark:inline bg-blue-500 p-1 rounded">☀️</span>
        </.link>
      </li>
    </ul>
    """
  end

  defp upload_error_to_string(:too_large), do: "Too large"
  defp upload_error_to_string(:too_many_files), do: "You have selected too many files"
  defp upload_error_to_string(:not_accepted), do: "You have selected an unacceptable file type"
end
