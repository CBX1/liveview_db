defmodule PokemonDb.Repo.Migrations.CreateAbilities do
  use Ecto.Migration

  def change do
    create table(:abilities) do
      add :name, :string
      add :internal_name, :string
      add :description, :string
    end
    create index("abilities", :internal_name, unique: true)
  end
end
