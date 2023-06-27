defmodule ChiyaWeb.AdminHomeLive do
  use ChiyaWeb, :live_view

  @impl true
  def mount(_params, _session, socket) do
    changeset = Chiya.Notes.change_note(%Chiya.Notes.Note{})
    {:ok, socket |> assign(:form, to_form(changeset))}
  end

  @impl true
  def handle_event("validate", %{"note" => params}, socket) do
    form =
      %Chiya.Notes.Note{}
      |> Chiya.Notes.change_note(params)
      |> Map.put(:action, :insert)
      |> to_form()

    {:noreply, assign(socket, form: form)}
  end

  @impl true
  def handle_event("save", %{"note" => params}, socket) do
    name = Chiya.Notes.Note.note_title(params["content"])
    settings = Chiya.Site.get_settings()

    params =
      params
      |> Map.put_new("name", name)
      |> Map.put_new("channels", [settings.home_channel])
      |> Map.put_new("published_at", NaiveDateTime.local_now())

    case Chiya.Notes.create_note(params) do
      {:ok, _note} ->
        {:noreply, socket |> put_flash(:info, "Note created!")}

      {:error, %Ecto.Changeset{} = changeset} ->
        IO.inspect(changeset)

        {:noreply,
         socket |> put_flash(:error, "Could not create note!") |> assign(form: to_form(changeset))}
    end
  end

  @impl true
  def render(assigns) do
    ~H"""
    <.header>
      <.icon name="hero-document-text" /> Welcome back!
      <:subtitle>This is the admin area</:subtitle>
      <:actions>
        <.link href={~p"/user"}>
          <.button>Profile</.button>
        </.link>
        <.link
          href={~p"/user/log_out"}
          method="delete"
          data-confirm="Do you want to logout?"
          class="text-sm leading-6 text-gray-900 dark:text-gray-100 dark:hover:text-gray-300 hover:text-gray-700"
        >
          <.button>Log out</.button>
        </.link>
      </:actions>
    </.header>

    <section>
      <.simple_form for={@form} phx-change="validate" phx-submit="save">
        <.input field={@form[:content]} type="textarea" />
        <:actions>
          <.button>Save</.button>
        </:actions>
      </.simple_form>
    </section>
    """
  end
end
