defmodule Chiya.SiteFixtures do
  @moduledoc """
  This module defines test helpers for creating
  entities via the `Chiya.Site` context.
  """

  @doc """
  Generate a setting.
  """
  def setting_fixture(attrs \\ %{}) do
    {:ok, setting} =
      attrs
      |> Enum.into(%{
        custom_css: "some custom_css",
        custom_html: "some custom_html",
        subtitle: "some subtitle",
        theme: :default,
        title: "some title",
        user_agent: "some user_agent"
      })
      |> Chiya.Site.create_setting()

    setting
  end
end
