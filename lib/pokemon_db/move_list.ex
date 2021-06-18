defmodule PokemonDb.MoveList do
  use Ecto.Schema
  import Ecto.Changeset

  schema "move_list" do
    field :name, :string
    field :moves, {:array, :integer}
  end

  @doc false
  def changeset(move_list, attrs \\ %{}) do
    move_list
    |> change(attrs)
    |> validate_required([:name])
    |> unique_constraint([:name])
  end
end
