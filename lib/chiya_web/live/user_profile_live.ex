defmodule ChiyaWeb.UserProfileLive do
  use ChiyaWeb, :live_view

  def render(assigns) do
    ~H"""
    <.header>
      User Profile
      <:actions>
        <.link href={~p"/user/settings"}>
          <.button>Edit User</.button>
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

    <.list>
      <:item title="Name"><%= @current_user.name %></:item>
      <:item title="Handle"><%= @current_user.handle %></:item>
      <:item title="Bio"><%= @current_user.bio %></:item>
      <:item title="Email"><%= @current_user.email %></:item>
    </.list>
    """
  end
end
