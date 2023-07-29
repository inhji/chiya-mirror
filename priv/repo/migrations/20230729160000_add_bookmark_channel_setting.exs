defmodule Chiya.Repo.Migrations.AddBookmarkChannelSetting do
  use Ecto.Migration

  def change do
    alter table(:settings) do
      add :bookmark_channel_id, references(:channels, on_delete: :nothing)
    end
  end
end