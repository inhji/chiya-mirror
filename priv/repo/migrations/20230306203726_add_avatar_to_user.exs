defmodule Chiya.Repo.Migrations.AddAvatarToUser do
  use Ecto.Migration

  def change do
    alter table(:users) do
      add :user_image, :string
    end
  end
end
