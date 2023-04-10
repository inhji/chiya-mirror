defmodule Chiya.Repo.Migrations.FixNoteImageReference do
  use Ecto.Migration

  def up do
    drop constraint(:note_images, "note_images_note_id_fkey")

    alter table(:note_images) do
      modify :note_id, references(:notes, on_delete: :delete_all)
    end
  end

  def down do
    drop constraint(:note_images, "note_images_note_id_fkey")

    alter table(:note_images) do
      modify :note_id, references(:notes, on_delete: :nothing)
    end
  end
end
