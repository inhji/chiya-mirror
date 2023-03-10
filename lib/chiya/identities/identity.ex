defmodule Chiya.Identities.Identity do
  use Ecto.Schema
  import Ecto.Changeset

  schema "identities" do
    field :name, :string
    field :url, :string
    field :rel, :string, default: "me"
    field :icon, :string, default: "cube"

    field :public, :boolean, default: false
    field :active, :boolean, default: false

    timestamps()
  end

  @doc false
  def changeset(identity, attrs) do
    identity
    |> cast(attrs, [:name, :rel, :url, :icon, :public, :active])
    |> validate_required([:name, :rel, :url, :icon])
  end
end
