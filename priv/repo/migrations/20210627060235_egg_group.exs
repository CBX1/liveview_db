defmodule PokemonDb.Repo.Migrations.EggGroup do
  use Ecto.Migration

  def change do
    alter table(:pokemons) do
      add :egg_group, {:array, :string}
    end
  end
end
