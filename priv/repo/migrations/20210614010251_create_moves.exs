defmodule PokemonDb.Repo.Migrations.CreateMoves do
  use Ecto.Migration

  def change do
    create table(:moves) do
      add :name, :string
      add :learn, :string
      add :pokemon_id, references(:pokemons)
    end

  end
end
