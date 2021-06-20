defmodule PokemonDb.Repo.Migrations.AddMoveDescrip do
  use Ecto.Migration

  def change do
    alter table(:move_list) do
      add :internal_name, :string
      add :power, :id
      add :description, :string
      add :forc, :string
      add :type, :string
      add :acc, :id
      add :basepp, :id
    end
  end
end
