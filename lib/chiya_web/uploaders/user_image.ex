defmodule Chiya.UserImage do
  use Waffle.Definition
  use Waffle.Ecto.Definition

  # Include ecto support (requires package waffle_ecto installed):
  # use Waffle.Ecto.Definition

  @versions [:original, :thumb]

  # Whitelist file extensions:
  def validate({file, _}) do
    file_extension = file.file_name |> Path.extname() |> String.downcase()

    # case Enum.member?(~w(.jpg .jpeg .gif .png), file_extension) do
    #   true -> :ok
    #   false -> {:error, "invalid file type"}
    # end

    # filetype will be validated in liveview
    :ok
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
  def storage_dir(_version, {_file, _scope}) do
    "uploads/user/avatar"
  end

  # Provide a default URL if there hasn't been a file uploaded
  # def default_url(version, scope) do
  #   "/images/avatars/default_#{version}.png"
  # end

  # Specify custom headers for s3 objects
  # Available options are [:cache_control, :content_disposition,
  #    :content_encoding, :content_length, :content_type,
  #    :expect, :expires, :storage_class, :website_redirect_location]
  #
  # def s3_object_headers(version, {file, scope}) do
  #   [content_type: MIME.from_path(file.file_name)]
  # end
end
