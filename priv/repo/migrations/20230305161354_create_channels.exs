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
  end
end
