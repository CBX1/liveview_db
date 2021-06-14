defmodule PokemonDbWeb.SearchLive do
  use PokemonDbWeb, :live_view
  alias PokemonDb.Repo
  def mount(_params, _session, socket) do
    socket =
      socket
      |> assign(:pokemon_name, "")
      |> assign(:pokemons, [])

    {:ok, socket}
  end

  def handle_event(
        "pokemon_name_search",
        %{"pokemon_name" => pokemon_name},
        socket
      ) do

    {:ok, data} =Repo.query("SELECT pok.name, pok.type1, pok.type2, array_agg(loc.name) FROM pokemons pok LEFT JOIN pokemons_locations po ON pok.id = po.pokemon_id LEFT JOIN locations loc ON loc.id = po.location_id WHERE pok.name LIKE '%#{pokemon_name}%' GROUP BY 1,2,3;")
    pokemons = data.rows
    socket =
      socket
      |> assign(:pokemon_name, pokemon_name)
      |> assign(:pokemons, pokemons)

    {:noreply, socket}
  end
end
