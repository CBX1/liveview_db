defmodule PokemonDb.Move do
  use Ecto.Schema

  schema "moves" do
    field :name, :string
    field :learn, :string
    belongs_to :pokemon, PokemonDb.Pokemon
  end
end
