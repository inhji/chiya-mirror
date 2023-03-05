defmodule Chiya.Repo.Migrations.CreateChannels do
  use Ecto.Migration

  def change do
    create table(:channels) do
      add :name, :string
      add :content, :text
      add :visibility, :string
      add :slug, :string

      timestamps()
    end

    create unique_index(:channels, [:slug])
  end
end
