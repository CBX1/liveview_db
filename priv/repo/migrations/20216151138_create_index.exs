defmodule PokemonDb.Repo.Migrations.CreateIndex do
  use Ecto.Migration

  def change do
    create index("pokemons", :name)
    create index("locations", :name, unique: true)
  end


end
