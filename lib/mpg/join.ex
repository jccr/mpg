defmodule Mpg.Join do
  use Ecto.Schema
  import Ecto.Changeset

  embedded_schema do
    field(:code, :string)
  end

  def changeset(join, params \\ %{}) do
    join
    |> cast(params, [:code])
    |> validate_required([:code])
    |> validate_format(:code, ~r/^[A-Z0-9]+$/)
    |> validate_length(:code, is: 4)
  end
end
