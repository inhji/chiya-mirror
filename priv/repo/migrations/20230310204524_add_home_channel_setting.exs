defmodule Chiya.Repo.Migrations.AddHomeChannelSetting do
  use Ecto.Migration

  def change do
    alter table(:settings) do
      add :home_channel_id, references(:channels, on_delete: :nothing)
    end
  end
end
