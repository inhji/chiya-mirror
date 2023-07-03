defmodule Chiya.Repo.Migrations.AddWikiChannelSetting do
  use Ecto.Migration

  def change do
    alter table(:settings) do
      add :wiki_channel_id, references(:channels, on_delete: :nothing)
    end
  end
end
