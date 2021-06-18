defmodule PokemonDb.BaseStat do
  use Ecto.Schema

  embedded_schema  do
    field :ATK, :id
    field :DEF, :id
    field :HP, :id
    field :SPEED, :id
    field :"Sp. ATK", :id
    field :"Sp. DEF", :id

  end



end
