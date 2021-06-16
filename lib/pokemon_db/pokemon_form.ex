defmodule PokemonDb.PokemonForm do
  use Ecto.Schema
  import Ecto.Changeset

  schema  "pokemon_form" do
    field :name, :string
    field :move, :string
    field :ability, :string
    field :growth_rate, :string
    field :location, :string
    field :type1, :string
    field :type2, :string
  end

  def changeset(pokemon_data, params \\ %{}) do
    pokemon_data
      |> cast(params, [:name, :move, :ability, :growth_rate, :location, :type1, :type2])
  end

end
