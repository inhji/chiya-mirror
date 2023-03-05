defmodule Chiya.Repo.Migrations.CreateChannelsNotes do
  use Ecto.Migration

  def change do
    create table(:channels_notes) do
      add :channel, references(:channels, on_delete: :nothing)
      add :note, references(:notes, on_delete: :nothing)

      timestamps()
    end

    create index(:channels_notes, [:channel])
    create index(:channels_notes, [:note])
  end
end
