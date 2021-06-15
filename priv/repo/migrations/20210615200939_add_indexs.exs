defmodule PokemonDb.Repo.Migrations.AddIndexs do
  use Ecto.Migration


  def change do
    create index("pokemons", :name)
    create index("locations", :name, unique: true)
  end


end
