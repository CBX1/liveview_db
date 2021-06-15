defmodule PokemonDb.Location do
  use Ecto.Schema
  import Ecto.Changeset

  schema "locations" do
    field :name, :string
    field :encounterChance, {:map, :id}
    field :encounterPresent, {:map, {:array, :string}}
    many_to_many :pokemon, PokemonDb.Pokemon, join_through: "pokemons_locations"
  end

  def changeset(location, params \\ %{}) do
    location
      |> change(params)
      |> validate_required([:name, :encounterChance, :encounterPresent])
      |> unique_constraint(:name)

  end
end
