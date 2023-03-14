defmodule Chiya.Repo.Migrations.ChangeIdentityIconToText do
  use Ecto.Migration

  def change do
    alter table(:identities) do
      modify :icon, :text, from: :string
    end
  end
end
