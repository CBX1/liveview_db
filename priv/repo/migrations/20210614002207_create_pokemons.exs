defmodule PokemonDb.Repo.Migrations.CreatePokemons do
  use Ecto.Migration

  def change do
    create table(:pokemons) do
      add :p_num, :integer
      add :name, :string
      add :description, :string
      add :type1, :string
      add :type2, :string
      add :hidden_ability, :string
      add :regular_abilities, {:array, :string}
      add :evolution, {:array, {:map, :string}}
      add :growth_rate, :string
    end

  end
end
