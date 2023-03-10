defmodule Chiya.Repo.Migrations.AddDefaultSettings do
  use Ecto.Migration

  alias Chiya.Site.Setting

  def up do
    if not repo().exists?(Setting) do
      repo().insert(%Setting{})
    end
  end

  def down do
    repo().delete_all(Setting)
  end
end
