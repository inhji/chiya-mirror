defmodule Chiya.Site do
  @moduledoc """
  The Site context.
  """

  import Ecto.Query, warn: false
  alias Chiya.Repo
  alias Chiya.Site.Setting

  @preloads [:home_channel, :default_channel, :micropub_channel]
  @default_settings %{
    title: "Site Title",
    subtitle: "Subtitle",
    theme: "default",
    custom_css: "",
    custom_html: ""
  }

  @doc """
  Gets a setting row, containing the settings.
  """
  def get_settings() do
    case Repo.one(Setting) do
      nil -> @default_settings
      setting -> Repo.preload(setting, @preloads)
    end
  end

  @doc """
  Creates a setting row.

  ## Examples

      iex> create_setting(%{field: value})
      {:ok, %Setting{}}

      iex> create_setting(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_setting(attrs \\ %{}) do
    %Setting{}
    |> Setting.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Updates the setting row.

  ## Examples

      iex> update_setting(setting, %{field: new_value})
      {:ok, %Setting{}}

      iex> update_setting(setting, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_setting(%Setting{} = setting, attrs) do
    setting
    |> Setting.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking setting changes.

  ## Examples

      iex> change_setting(setting)
      %Ecto.Changeset{data: %Setting{}}

  """
  def change_setting(%Setting{} = setting, attrs \\ %{}) do
    Setting.changeset(setting, attrs)
  end
end
