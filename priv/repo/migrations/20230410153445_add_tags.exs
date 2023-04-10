defmodule Chiya.Repo.Migrations.AddTags do
  use Ecto.Migration

  def change do
    create table(:tags) do
      add :name, :string
      add :slug, :string
      add :content, :text
      add :icon, :string
      add :regex, :string

      timestamps()
    end

    create table(:notes_tags) do
      add :note_id, references(:notes, on_delete: :delete_all)
      add :tag_id, references(:tags, on_delete: :delete_all)
    end

    create unique_index(:tags, [:slug])
    create unique_index(:tags, [:name])
    create unique_index(:notes_tags, [:note_id, :tag_id])
  end
end
