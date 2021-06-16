defmodule PokemonDb.PokemonLocation do
  alias PokemonDb.Pokemon
  alias PokemonDb.Location
  import Ecto.Changeset
  use Ecto.Schema

  schema "pokemons_locations" do
    belongs_to(:pokemon, Pokemon )
    belongs_to(:location, Location)
  end

  def changeset(pokemon_locations, params \\ %{}) do
    pokemon_locations
      |> change(params)
      |> validate_required([:pokemon_id,:location_id])
      |> validate_number(:pokemon_id, greater_than_or_equal_to: 1)
      |> validate_number(:location_id, greater_than_or_equal_to: 1)
      |> unique_constraint([:pokemon_id, :location_id])
  end
end





