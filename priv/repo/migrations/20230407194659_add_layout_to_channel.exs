defmodule Chiya.Repo.Migrations.AddLayoutToChannel do
  use Ecto.Migration

  def change do
    alter table(:channels) do
      add :layout, :string, default: "default"
    end
  end
end
