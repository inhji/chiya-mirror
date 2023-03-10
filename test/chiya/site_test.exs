defmodule Chiya.SiteTest do
  use Chiya.DataCase

  alias Chiya.Site

  describe "settings" do
    alias Chiya.Site.Setting

    import Chiya.SiteFixtures

    @invalid_attrs %{
      custom_css: nil,
      custom_html: nil,
      subtitle: nil,
      theme: nil,
      title: nil,
      user_agent: nil
    }

    test "get_setting!/1 returns the setting" do
      # setting = setting_fixture()
      setting = Site.get_settings()
      assert setting.title == "Title"
      assert setting.subtitle == "Subtitle"
    end

    test "create_setting/1 with valid data creates a setting" do
      valid_attrs = %{
        custom_css: "some custom_css",
        custom_html: "some custom_html",
        subtitle: "some subtitle",
        theme: :default,
        title: "some title",
        user_agent: "some user_agent"
      }

      assert {:ok, %Setting{} = setting} = Site.create_setting(valid_attrs)
      assert setting.custom_css == "some custom_css"
      assert setting.custom_html == "some custom_html"
      assert setting.subtitle == "some subtitle"
      assert setting.theme == :default
      assert setting.title == "some title"
      assert setting.user_agent == "some user_agent"
    end

    test "create_setting/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Site.create_setting(@invalid_attrs)
    end

    test "update_setting/2 with valid data updates the setting" do
      setting = Site.get_settings()

      update_attrs = %{
        custom_css: "some updated custom_css",
        custom_html: "some updated custom_html",
        subtitle: "some updated subtitle",
        theme: :default,
        title: "some updated title",
        user_agent: "some updated user_agent"
      }

      assert {:ok, %Setting{} = setting} = Site.update_setting(setting, update_attrs)
      assert setting.custom_css == "some updated custom_css"
      assert setting.custom_html == "some updated custom_html"
      assert setting.subtitle == "some updated subtitle"
      assert setting.theme == :default
      assert setting.title == "some updated title"
      assert setting.user_agent == "some updated user_agent"
    end

    test "update_setting/2 with invalid data returns error changeset" do
      setting = Site.get_settings()
      assert {:error, %Ecto.Changeset{}} = Site.update_setting(setting, @invalid_attrs)
      assert setting == Site.get_settings()
    end

    test "change_setting/1 returns a setting changeset" do
      setting = setting_fixture()
      assert %Ecto.Changeset{} = Site.change_setting(setting)
    end
  end
end
