defmodule ChiyaWeb.SettingController do
  use ChiyaWeb, :controller

  alias Chiya.Site
  alias Chiya.Site.Setting

  def new(conn, _params) do
    changeset = Site.change_setting(%Setting{})
    render(conn, :new, changeset: changeset, channels: channels())
  end

  def create(conn, %{"setting" => setting_params}) do
    case Site.create_setting(setting_params) do
      {:ok, _setting} ->
        conn
        |> put_flash(:info, "Setting created successfully.")
        |> redirect(to: ~p"/admin/settings")

      {:error, %Ecto.Changeset{} = changeset} ->
        render(conn, :new, changeset: changeset, channels: channels())
    end
  end

  def show(conn, _params) do
    setting = Site.get_settings()
    render(conn, :show, setting: setting)
  end

  def edit(conn, _params) do
    setting = Site.get_settings()
    changeset = Site.change_setting(setting)
    render(conn, :edit, setting: setting, changeset: changeset, channels: channels())
  end

  def update(conn, %{"setting" => setting_params}) do
    setting = Site.get_settings()

    case Site.update_setting(setting, setting_params) do
      {:ok, _setting} ->
        conn
        |> put_flash(:info, "Setting updated successfully.")
        |> redirect(to: ~p"/admin/settings")

      {:error, %Ecto.Changeset{} = changeset} ->
        render(conn, :edit, setting: setting, changeset: changeset, channels: channels())
    end
  end

  defp channels(), do: Chiya.Channels.list_channels() |> Enum.map(fn c -> {c.name, c.id} end)
end
