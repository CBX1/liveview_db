defmodule PokemonDb.Repo.Migrations.CreateMoveList do
  use Ecto.Migration

  def change do
    create table(:move_list) do
      add :name, :string
      add :moves, {:array, :integer}

    end
    create index("move_list", :name, unique: true)

  end
end
