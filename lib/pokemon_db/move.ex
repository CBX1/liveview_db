defmodule PokemonDb.Move do
  use Ecto.Schema
  import Ecto.Changeset
  schema "moves" do
    field :name, :string
    field :learn, :string
    belongs_to :pokemon, PokemonDb.Pokemon
  end


  def changeset(move, params \\ %{}) do
    move
      |> change(params)
      |> validate_required([:name, :learn])
  end

end
