defmodule PokemonDb.Move do
  use Ecto.Schema

  embedded_schema  do
    field :name, :string
    field :learn, :string
  end




end
