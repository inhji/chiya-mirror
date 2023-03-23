defmodule ChiyaWeb.Uploaders.NoteImage do
  use Waffle.Definition
  use Waffle.Ecto.Definition

  # Include ecto support (requires package waffle_ecto installed):
  # use Waffle.Ecto.Definition

  @versions [:original, :full, :full_dithered, :thumb, :thumb_dithered]

  # Whitelist file extensions:
  def validate({_file, _}) do
    # _file_extension = file.file_name |> Path.extname() |> String.downcase()
    # case Enum.member?(~w(.jpg .jpeg .gif .png), file_extension) do
    #   true -> :ok
    #   false -> {:error, "invalid file type"}
    # end

    # filetype will be validated in liveview
    :ok
  end

  def transform(:full, _) do
    {:convert, "-strip -resize 1500000@ -gravity center -format png", :png}
  end

  # Define a resize transformation:
  def transform(:full_dithered, _) do
    {:convert, "-strip -resize 1500000@ -colors 24 -dither FloydSteinberg -format png", :png}
  end

  # Define a thumbnail transformation:
  def transform(:thumb, _) do
    {:convert, "-strip -thumbnail 250x250^ -gravity center -extent 250x250 -format png", :png}
  end

  # Define a thumbnail transformation with dithering:
  def transform(:thumb_dithered, _) do
    {:convert,
     "-strip -thumbnail 250x250^ -gravity center -extent 250x250 -colors 24 -dither FloydSteinberg -format png",
     :png}
  end

  # Override the persisted filenames:
  def filename(version, _) do
    version
  end

  # Override the storage directory:
  def storage_dir(_version, {_file, %{id: image_id, note_id: note_id}}) do
    "uploads/note/#{note_id}/#{image_id}"
  end

  # Provide a default URL if there hasn't been a file uploaded
  # def default_url(version, scope) do
  #   "/images/avatars/default_#{version}.png"
  # end
end
