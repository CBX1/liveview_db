defmodule PokemonDb.Repo.Migrations.CreateLocations do
  use Ecto.Migration

  def change do
    create table(:pokemons_locations) do
      add :pokemon_id, references(:pokemons)
      add :location_id, references(:locations)
    end
  end
end
