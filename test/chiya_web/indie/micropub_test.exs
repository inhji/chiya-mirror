defmodule ChiyaWeb.MicropubTest do
  use Chiya.DataCase

  alias ChiyaWeb.Indie.Micropub

  @valid_props %{
    "content" => ["this is a test"]
  }

  describe "create_note/3" do
    test "creates a note with valid attributes" do
      assert {:ok, :created, url} =
               Micropub.create_note("entry", @valid_props, nil)

      assert url =~ "this-is-a-test"
    end
  end
end
