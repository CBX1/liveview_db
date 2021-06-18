defmodule PokemonDb.Repo.Migrations.AddIndexs do
  use Ecto.Migration


  def change do
    create index("pokemons", :name)
    create index("locations", :name, unique: true)
   create index("pokemons_locations", [:pokemon_id, :location_id], unique: true)
   create index("pokemons", :internal_name, unique: true)
  end


end
