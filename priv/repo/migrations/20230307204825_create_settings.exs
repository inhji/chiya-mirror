defmodule Chiya.Repo.Migrations.CreateSettings do
  use Ecto.Migration

  def change do
    create table(:settings) do
      add :title, :string
      add :subtitle, :string
      add :theme, :string
      add :user_agent, :string
      add :custom_css, :text
      add :custom_html, :text

      timestamps()
    end
  end
end
