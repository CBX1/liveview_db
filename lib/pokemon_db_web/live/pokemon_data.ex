defmodule PokemonDbWeb.PokemonLive do
  use PokemonDbWeb, :live_view
  import Ecto.Query
  import Ecto.Changeset
  alias PokemonDbWeb.Router.Helpers, as: Routes
  alias PokemonDbWeb.SearchLive
  alias PokemonDb.{
    Repo,
    Pokemon,
    PokemonLocation,
    Location,
    Move,
    BaseStat,
    PokemonForm,

  }
  def mount(_params, _session, socket) do
    socket = socket |> assign(:namee, "") |> assign(:main_data, "") |> assign(:moves, "")
    {:ok, socket}
  end

  def handle_params(%{"name" => id} = _params, _uri, socket) do


    socket = socket |> assign(:namee, id)
    {:noreply, socket}
  end

  def handle_event("home",params, socket) do


    {:noreply,  push_redirect(socket, to: Routes.live_path(socket, SearchLive, params))}
  end

  def handle_params(params, _uri, socket) do
    IO.inspect params

    set = from( p in Pokemon, as: :pkmn, join: m in Move, as: :move, on: m.pokemon_id == p.id, select: %{id: p.id, internal_name: p.internal_name, name: p.name, description: p.description, type1: p.type1, type2: p.type2, hidden_ability: p.hidden_ability, regular_abilities: p.regular_abilities, evolution: p.evolution, growth_rate: p.growth_rate,  moves: fragment("array_agg(?)",m)}, group_by: p.id, where: p.internal_name == ^params["pokemon"])
    sp = from(p in BaseStat, join: s in subquery(set), on: s.id == p.pokemon_id, select: %{id: s.id, name: s.name,description: s.description, internal_name: s.internal_name, type1: s.type1, type2: s.type2, hidden_ability: s.hidden_ability, regular_abilities: s.regular_abilities, evolution: s.evolution, growth_rate: s.growth_rate, moves: s.moves, atk: p."ATK", def: p."DEF", speed: p."SPEED", spd: p."Sp. DEF", spa: p."Sp. ATK", hp: p."HP" })
     mm = from(pl in PokemonLocation, join: l in Location, on: l.id == pl.location_id, right_join: s in subquery(sp), on: s.id == pl.pokemon_id, select: %{ atk: s.atk, def: s.def, speed: s.speed, spd: s.spd , spa: s.spa, hp: s.hp, type1: s.type1, description: s.description, hidden_ability: s.hidden_ability, regular_abilities: s.regular_abilities, evolution: s.evolution,moves: s.moves, growth_rate: s.growth_rate, internal_name: s.internal_name, name: s.name, type2: s.type2, id: s.id, l: fragment("array_agg(?)", l.name)}, group_by: [s.internal_name, s.id, s.name, s.description, s.type1, s.type2, s.hidden_ability, s.regular_abilities, s.evolution, s.growth_rate, s.moves, s.atk, s.def, s.speed, s.spd, s.spa, s.hp])
    pokemons = Repo.all(mm)

    # movs = (pokemons |> hd).moves |> Enum.flatten
    socket = socket |> assign(:main_data, pokemons |> hd) #|> assign(:moves, movs)
    {:noreply, socket}
  end


  def handle_event("test",%{"pname" => tes}, socket) do
    {:noreply,  push_redirect(socket, to: Routes.live_path(socket, PokemonDbWeb.PokemonLive, tes))}
  end
end
