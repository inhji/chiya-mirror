defmodule Chiya.Repo.Migrations.AddBooleanSettings do
  use Ecto.Migration

  def change do
    alter table(:settings) do
      add :show_images_on_home, :boolean, default: true
    end
  end
end
