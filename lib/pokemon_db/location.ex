defmodule PokemonDb.Location do
  use Ecto.Schema


  schema "locations" do
    field :name, :string
    field :encounterChance, {:map, :id}
    field :encounterPresent, {:map, {:array, :string}}
    many_to_many :pokemon, PokemonDb.Pokemon, join_through: "pokemons_locations"
  end

end
