defmodule Mpg.Player do
  use Ecto.Schema
  import Ecto.Changeset

  embedded_schema do
    field(:name, :string)
  end

  def changeset(player, params \\ %{}) do
    player
    |> cast(params, [:name])
    |> validate_required([:name])
    |> validate_length(:name, min: 1, max: 12)
  end
end
