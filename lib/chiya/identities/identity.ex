defmodule Chiya.Identities.Identity do
  use Ecto.Schema
  import Ecto.Changeset

  schema "identities" do
    field :active, :boolean, default: false
    field :name, :string
    field :public, :boolean, default: false
    field :rel, :string
    field :url, :string
    field :icon, :string

    timestamps()
  end

  @doc false
  def changeset(identity, attrs) do
    identity
    |> cast(attrs, [:name, :rel, :url, :public, :active, :icon])
    |> validate_required([:name, :rel, :url, :public, :active, :icon])
  end
end
