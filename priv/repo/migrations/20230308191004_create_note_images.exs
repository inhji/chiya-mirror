defmodule Chiya.Repo.Migrations.CreateNoteImages do
  use Ecto.Migration

  def change do
    create table(:note_images) do
      add :path, :string
      add :content, :text
      add :note_id, references(:notes, on_delete: :nothing)

      timestamps()
    end

    create index(:note_images, [:note_id])
  end
end
