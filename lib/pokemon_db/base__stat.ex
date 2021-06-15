defmodule PokemonDb.BaseStat do
  use Ecto.Schema
  import Ecto.Changeset
  schema "base_stats" do
    field :ATK, :id
    field :DEF, :id
    field :HP, :id
    field :SPEED, :id
    field :"Sp. ATK", :id
    field :"Sp. DEF", :id

    belongs_to :pokemon, PokemonDb.Pokemon
  end

  def changeset(bst, params \\ %{}) do
    bst
    |> change(params)
    |> validate_required([:ATK, :DEF, :HP, :"Sp. ATK", :"Sp. DEF"])
    |> validate_number(:ATK, greater_than_or_equal_to: 0)
    |> validate_number(:DEF, greater_than_or_equal_to: 0)
    |> validate_number(:HP, greater_than_or_equal_to: 0)
    |> validate_number(:"Sp. ATK", greater_than_or_equal_to: 0)
    |> validate_number(:"Sp. DEF", greater_than_or_equal_to: 0)

  end

end
