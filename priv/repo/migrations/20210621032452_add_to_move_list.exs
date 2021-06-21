defmodule PokemonDb.Repo.Migrations.AddToMoveList do
  use Ecto.Migration

  def change do
      alter table(:move_list) do
        #  additional effect: integer, target: int, priority: int, al_code: string
        add :additional_effect, :integer
       add :target, :integer
       add :priority, :integer
       add :al_code, :string

      end
  end
end
