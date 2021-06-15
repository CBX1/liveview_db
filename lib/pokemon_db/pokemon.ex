defmodule PokemonDb.Pokemon do
    use Ecto.Schema
    import Ecto.Changeset
    schema "pokemons" do
      field :name, :string
      field :p_num, :integer
      field :description, :string
      field :type1, :string
      field :type2, :string
      field :hidden_ability, :string
      field :regular_abilities, {:array, :string}
      field :evolution, {:map, :string}
      field :growth_rate, :string
      has_many :moves, PokemonDb.Move
      many_to_many :location, PokemonDb.Location, join_through: "pokemons_locations"
      has_one :base_stats, PokemonDb.BaseStat
    end



    def changeset(pokemon, params \\ %{}) do
      pokemon
      |> change(params)
      |> validate_required([:name,:p_num,:type1,:regular_abilities,:description])


    end
  end
