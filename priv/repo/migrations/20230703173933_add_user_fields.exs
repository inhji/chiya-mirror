defmodule Chiya.Repo.Migrations.AddUserFields do
  use Ecto.Migration

  def change do
    alter table(:users) do
      add :handle, :string
      add :name, :string
      add :bio, :text
    end
  end
end
