defmodule PokemonDb.PokemonLocation do
  alias PokemonDb.Pokemon
  alias PokemonDb.Location
  use Ecto.Schema

  schema "pokemons_locations" do
    belongs_to(:pokemon, Pokemon )
    belongs_to(:location, Location)
  end

end
