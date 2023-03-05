defmodule Chiya.Repo.Migrations.CreateNotes do
  use Ecto.Migration

  def change do
    create table(:notes) do
      add :name, :string
      add :content, :text
      add :slug, :string
      add :published_at, :naive_datetime
      add :kind, :string
      add :url, :string

      timestamps()
    end

    create unique_index(:notes, [:slug])
  end
end
