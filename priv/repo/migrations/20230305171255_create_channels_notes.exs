defmodule Chiya.Repo.Migrations.CreateChannelsNotes do
  use Ecto.Migration

  def change do
    create table(:channels_notes, primary_key: false) do
      add :channel, references(:channels, on_delete: :delete_all)
      add :note, references(:notes, on_delete: :delete_all)
    end

    create index(:channels_notes, [:channel])
    create index(:channels_notes, [:note])
  end
end
