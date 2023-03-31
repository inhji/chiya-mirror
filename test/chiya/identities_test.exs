defmodule Chiya.IdentitiesTest do
  use Chiya.DataCase

  alias Chiya.Identities

  describe "identities" do
    alias Chiya.Identities.Identity

    import Chiya.IdentitiesFixtures

    @invalid_attrs %{active: nil, name: nil, public: nil, rel: nil, url: nil}

    test "list_identities/0 returns all identities" do
      identity = identity_fixture()
      assert Identities.list_identities() == [identity]
    end

    test "get_identity!/1 returns the identity with given id" do
      identity = identity_fixture()
      assert Identities.get_identity!(identity.id) == identity
    end

    test "create_identity/1 with valid data creates a identity" do
      valid_attrs = %{
        active: true,
        name: "some name",
        public: true,
        rel: "some rel",
        url: "some url",
        icon: "some icon"
      }

      assert {:ok, %Identity{} = identity} = Identities.create_identity(valid_attrs)
      assert identity.active == true
      assert identity.name == "some name"
      assert identity.public == true
      assert identity.rel == "some rel"
      assert identity.url == "some url"
      assert identity.icon == "some icon"
    end

    test "create_identity/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Identities.create_identity(@invalid_attrs)
    end

    test "update_identity/2 with valid data updates the identity" do
      identity = identity_fixture()

      update_attrs = %{
        active: false,
        name: "some updated name",
        public: false,
        rel: "some updated rel",
        url: "some updated url",
        icon: "some updated icon"
      }

      assert {:ok, %Identity{} = identity} = Identities.update_identity(identity, update_attrs)
      assert identity.active == false
      assert identity.name == "some updated name"
      assert identity.public == false
      assert identity.rel == "some updated rel"
      assert identity.url == "some updated url"
      assert identity.icon == "some updated icon"
    end

    test "update_identity/2 with invalid data returns error changeset" do
      identity = identity_fixture()
      assert {:error, %Ecto.Changeset{}} = Identities.update_identity(identity, @invalid_attrs)
      assert identity == Identities.get_identity!(identity.id)
    end

    test "delete_identity/1 deletes the identity" do
      identity = identity_fixture()
      assert {:ok, %Identity{}} = Identities.delete_identity(identity)
      assert_raise Ecto.NoResultsError, fn -> Identities.get_identity!(identity.id) end
    end

    test "change_identity/1 returns a identity changeset" do
      identity = identity_fixture()
      assert %Ecto.Changeset{} = Identities.change_identity(identity)
    end
  end
end
