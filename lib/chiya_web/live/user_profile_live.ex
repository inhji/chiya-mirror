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
