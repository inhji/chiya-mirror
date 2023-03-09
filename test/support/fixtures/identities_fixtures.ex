defmodule Chiya.IdentitiesFixtures do
  @moduledoc """
  This module defines test helpers for creating
  entities via the `Chiya.Identities` context.
  """

  @doc """
  Generate a identity.
  """
  def identity_fixture(attrs \\ %{}) do
    {:ok, identity} =
      attrs
      |> Enum.into(%{
        active: true,
        name: "some name",
        public: true,
        rel: "some rel",
        url: "some url"
      })
      |> Chiya.Identities.create_identity()

    identity
  end
end
