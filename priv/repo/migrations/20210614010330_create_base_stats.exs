defmodule PokemonDb.Repo.Migrations.CreateBaseStats do
  use Ecto.Migration
  def change do
    create table(:base_stats) do
      add :ATK, :id
      add :DEF, :id
      add :SPEED, :id
      add :HP, :id
      add :"Sp. ATK", :id
      add :"Sp. DEF", :id
      add :pokemon_id, references(:pokemons)
    end

  end
end
