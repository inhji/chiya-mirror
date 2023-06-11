defmodule Chiya.Repo.Migrations.AddDefaultMicropubChannelSetting do
  use Ecto.Migration

  def change do
    alter table(:settings) do
      add :micropub_channel_id, references(:channels, on_delete: :nothing)
    end
  end
end
