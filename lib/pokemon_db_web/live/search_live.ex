defmodule PokemonDbWeb.SearchLive do
  use PokemonDbWeb, :live_view
  alias PokemonDb.Repo
  @spec mount(any, any, Phoenix.LiveView.Socket.t()) :: {:ok, Phoenix.LiveView.Socket.t()}
  def mount(_params, _session, socket) do
    {:ok, pokemon_data} =Repo.query("SELECT pok.name, pok.type1, pok.type2, pok.growth_rate, array_agg(loc.name) FROM pokemons pok LEFT JOIN pokemons_locations po ON pok.id = po.pokemon_id LEFT JOIN locations loc ON loc.id = po.location_id GROUP BY 1,2,3,4;")
    pokemons = pokemon_data.rows

    # {:ok, ability_data} = Repo.query("SELECT distinct(UNNEST(regular_abilities)) from pokemons UNION SELECT distinct(hidden_ability) from pokemons ORDER BY unnest")
    # abilities = Enum.drop(ability_data.rows, -1)
    # {:ok, moves_data} = Repo.query("SELECT distinct(move.name) from pokemons p JOIN moves move ON move.pokemon_id = p.id ORDER BY name;")
    # moves = moves_data.rows
    socket =
      socket
      |> assign(:pokemon_name, "")
      |> assign(:pokemons, pokemons)


    {:ok, socket}
  end

  def handle_event(
        "pokemon_name_search",
        %{"pokemon_name" => pokemon_name},
        socket
      ) do

    pokemon_name1 = pokemon_name |> String.capitalize
    {:ok, data} =Repo.query("SELECT pok.name, pok.type1, pok.type2, pok.growth_rate, array_agg(loc.name) FROM pokemons pok LEFT JOIN pokemons_locations po ON pok.id = po.pokemon_id LEFT JOIN locations loc ON loc.id = po.location_id WHERE pok.name LIKE '%#{pokemon_name}%' OR pok.name LIKE '%#{pokemon_name1}%' GROUP BY 1,2,3,4;")
    pokemons = data.rows
    socket =
      socket
      |> assign(:pokemon_name, pokemon_name)
      |> assign(:pokemons, pokemons)
      |> assign(:advanced_query, true)


    {:noreply, socket}
  end

end
