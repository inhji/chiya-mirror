defmodule Chiya.Repo do
  use Ecto.Repo,
    otp_app: :chiya,
    adapter: Ecto.Adapters.Postgres
end
