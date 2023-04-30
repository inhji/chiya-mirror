defmodule Chiya.Repo.Migrations.CreateNoteComments do
  use Ecto.Migration

  def change do
    create table(:note_comments) do
      add :content, :text
      add :author_name, :string
      add :author_id, :integer
      add :kind, :string
      add :approved_at, :naive_datetime
      add :note_id, references(:notes, on_delete: :delete_all)

      timestamps()
    end

    create index(:note_comments, [:note_id])
  end
end
