defmodule PokemonDb.Repo.Migrations.Add_EVs do
  use Ecto.Migration

  def change do
    alter table(:pokemons) do
      add :ev, :jsonb
    end
  end
end
