defmodule PokemonDb.PokemonForm do
  use Ecto.Schema
  import Ecto.Changeset

  schema  "pokemon_form" do
    field :name, :string
    field :ability, :string
    field :growth_rate, :string
    field :location, :string
    field :type1, :string
    field :type2, :string
  end

  def changeset(pokemon_data, params \\ %{}) do
    IO.inspect params
    pokemon_data
      |> cast(params, [:name, :ability, :growth_rate, :location, :type1, :type2], empty_values: [])

  end

end
