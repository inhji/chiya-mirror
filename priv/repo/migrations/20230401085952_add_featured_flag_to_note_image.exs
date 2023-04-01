defmodule Chiya.Repo.Migrations.AddFeaturedFlagToNoteImage do
  use Ecto.Migration

  def change do
    alter table(:note_images) do
      add :featured, :boolean
    end
  end
end
