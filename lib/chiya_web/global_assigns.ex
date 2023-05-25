defmodule ChiyaWeb.GlobalAssigns do
  import Plug.Conn

  def fetch_settings(conn, _opts) do
    settings = Chiya.Site.get_settings()
    assign(conn, :settings, settings)
  end

  def fetch_identities(conn, _opts) do
    identities = Chiya.Identities.list_identities()

    conn
    |> assign(
      :identities,
      Enum.filter(identities, fn i -> i.active end)
    )
    |> assign(
      :public_identities,
      Enum.filter(identities, fn i -> i.public && i.active end)
    )
  end

  def fetch_public_channels(conn, _opts) do
    channels =
      Chiya.Channels.list_channels()
      |> Enum.filter(fn c -> c.visibility == :public end)

    assign(conn, :channels, channels)
  end
end
