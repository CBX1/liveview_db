defmodule PokemonDb.Pokemon do
    use Ecto.Schema
    import Ecto.Changeset
    schema "pokemons" do
      field :name, :string
      field :internal_name, :string
      field :p_num, :integer
      field :description, :string
      field :type1, :string
      field :type2, :string
      field :hidden_ability, :string
      field :regular_abilities, {:array, :string}
      field :evolution, {:array, {:map, :string}}
      field :growth_rate, :string
      many_to_many :location, PokemonDb.Location, join_through: "pokemons_locations"
      embeds_one :base_stat, PokemonDb.BaseStat, on_replace: :update
      embeds_many :moves, PokemonDb.Move, on_replace: :delete
      embeds_one :ev, PokemonDb.BaseStat, on_replace: :update


    end



    def changeset(pokemon, params \\ %{}) do
      pokemon
      |> change(params)
      |> validate_required([:name,:p_num,:type1,:regular_abilities,:description, :internal_name])
      |> unique_constraint(:internal_name)


    end
  end
