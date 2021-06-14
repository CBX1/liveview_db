defmodule PokemonDb.BaseStat do
  use Ecto.Schema

  schema "base_stats" do
    field :ATK, :id
    field :DEF, :id
    field :HP, :id
    field :SPEED, :id
    field :"Sp. ATK", :id
    field :"Sp. DEF", :id

    belongs_to :pokemon, PokemonDb.Pokemon
  end
end
