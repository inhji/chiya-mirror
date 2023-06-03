defmodule ChiyaWeb.Helpers do
  alias ChiyaWeb.Uploaders.NoteImage

  def image_url(image, :full) do
    NoteImage.url({image.path, image}, :full_dithered)
  end

  def image_url(image, :thumb) do
    NoteImage.url({image.path, image}, :thumb_dithered)
  end
end
