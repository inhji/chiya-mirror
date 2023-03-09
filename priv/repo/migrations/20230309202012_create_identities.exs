defmodule Chiya.Repo.Migrations.CreateIdentities do
  use Ecto.Migration

  def change do
    create table(:identities) do
      add :name, :string
      add :rel, :string
      add :url, :string
      add :public, :boolean, default: false, null: false
      add :active, :boolean, default: false, null: false
      add :icon, :string

      timestamps()
    end
  end
end
