defmodule Chiya.Repo.Migrations.AddDefaultChannelSetting do
  use Ecto.Migration

  def change do
    alter table(:settings) do
      add :default_channel_id, references(:channels, on_delete: :nothing)
    end
  end
end
