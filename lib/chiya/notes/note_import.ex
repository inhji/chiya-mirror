defmodule Chiya.Notes.NoteImport do
  import Ecto.Changeset

  defstruct [:file]

  @types %{file: :string}

  def change_note_import(params) do
    {%Chiya.Notes.NoteImport{}, @types}
    |> cast(params, Map.keys(@types))
    |> validate_required(:file)
  end
end
