defmodule PokemonDb.Repo.Migrations.CreatePokemonsLocations do
  use Ecto.Migration


  def change do
    create table(:locations) do
      add :name, :string
      add :encounterChance, {:map, :id}
      add :encounterPresent, {:map, {:array, :string}}
    end

  end
end

# Created the tables in the wrong order by accident
