defmodule PokemonDbWeb.SearchLive do
  use PokemonDbWeb, :live_view
  import Ecto.Query
  import Ecto.Changeset
  alias PokemonDbWeb.Router.Helpers, as: Routes
  alias PokemonDb.{
    Repo,
    Pokemon,
    PokemonLocation,
    Location,
    Move,
    BaseStat,
    PokemonForm,

  }
  alias PokemonDbWeb.PokemonLive

  @spec mount(any, any, Phoenix.LiveView.Socket.t()) :: {:ok, Phoenix.LiveView.Socket.t()}
  def mount(_params, _session, socket) do
    vv = from p in Pokemon,
        left_join: pl in PokemonLocation, on: p.id == pl.pokemon_id,
        left_join: l in Location, on: l.id == pl.location_id,
        select: %{type1: p.type1, type2: p.type2, id: p.id, internal_name: p.internal_name, name: p.name, l: fragment("array_agg(?)",l.name)},
        group_by: p.id, limit: 50

    # {:ok, ability_data} = Repo.query("SELECT distinct(UNNEST(regular_abilities)) from pokemons UNION SELECT distinct(hidden_ability) from pokemons ORDER BY unnest")
    # abilities = Enum.drop(ability_data.rows, -1)
    # {:ok, moves_data} = Repo.query("SELECT distinct(move.name) from pokemons p JOIN moves move ON move.pokemon_id = p.id ORDER BY name;")
    # moves = moves_data.rows
    moves_data = Repo.all( from m in "moves", select: m.name, distinct: m.name)
    yy = from wr in Pokemon, select: %{regular: wr.hidden_ability}, distinct: wr.hidden_ability
    q = from(a in Pokemon, select: %{ability: fragment("unnest(?)", a.regular_abilities)}, distinct: true )
    qq = from(b in subquery(q), union: ^yy, distinct: true)
    o = from(g in subquery(qq), select: g.ability, order_by: g.ability)
    growth_rate = ["Fluctuating","Erratic","Slow","Fast","Medium","Parabolic"]
    location_query = from n in Location, select: n.name, distinct: n.name, order_by: n.name
    locations = Repo.all(location_query)
    pokemons = Repo.all(vv)
    abilities = Repo.all(o) |> tl
    type_query = from p in Pokemon, select: p.type1, distinct: p.type1
    types = Repo.all(type_query)
    socket =
      socket
      |> assign(:pokemon_data, PokemonForm.changeset(%PokemonForm{}))
      |> assign(:pokemons, pokemons)
      |> assign(:moves, moves_data)
      |> assign(:selected_move, "")
      |> assign(:abilities, abilities)
      |> assign(:growth_rate, growth_rate)
      |> assign(:location, locations)
      |> assign(:types, types)


    {:ok, socket}
  end

  def handle_event(
        "pokemon_name_search",
        %{"pokemon_name" => pokemon_name},
        socket
      ) do

        set = from( p in Pokemon, as: :pkmn, join: m in Move, as: :move, on: m.pokemon_id == p.id, select: %{id: p.id, internal_name: p.internal_name, name: p.name, description: p.description, type1: p.type1, type2: p.type2, hidden_ability: p.hidden_ability, regular_abilities: p.regular_abilities, evolution: p.evolution, growth_rate: p.growth_rate,  moves: fragment("array_agg(?)",m)}, group_by: p.id, where: ilike(p.name,^"%#{pokemon_name}%") and (ilike(p.type1,^"%#{pokemon_name}%")  or ilike(p.name,^"%#{pokemon_name}%"))     )
        sp = from(p in BaseStat, join: s in subquery(set), on: s.id == p.pokemon_id, select: %{id: s.id, name: s.name, internal_name: s.internal_name, description: s.description, type1: s.type1, type2: s.type2, hidden_ability: s.hidden_ability, regular_abilities: s.regular_abilities, evolution: s.evolution, growth_rate: s.growth_rate, moves: s.moves, atk: p."ATK", def: p."DEF", speed: p."SPEED", spd: p."Sp. DEF", spa: p."Sp. ATK", hp: p."HP" })
        mm = from(pl in PokemonLocation, join: l in Location, on: l.id == pl.location_id, right_join: s in subquery(sp), on: s.id == pl.pokemon_id, select: %{type1: s.type1, name: s.name, type2: s.type2, id: s.id, l: fragment("array_agg(?)", l.name)}, group_by: [s.id, s.name, s.description, s.type1, s.type2, s.hidden_ability, s.regular_abilities, s.evolution, s.growth_rate, s.moves, s.atk, s.def, s.speed, s.spd, s.spa, s.hp], where: fragment("? LIKE '%%'", s.name))



    pokemon_name1 = pokemon_name |> String.capitalize
    pokemon_name = pokemon_name |> String.downcase
    pokemons = Repo.all(mm)
    socket =
      socket
        |> assign(:pokemon_name, pokemon_name)
        |> assign(:pokemons, pokemons)
        |> assign(:advanced_query, true)


    {:noreply, socket}
    end


    def handle_event("pokemon_new", %{"pokemon_form" => params}, socket) do
        changeset = PokemonForm.changeset(%PokemonForm{},params)
        set = from( p in Pokemon, as: :pkmn, join: m in Move, as: :move, on: m.pokemon_id == p.id, select: %{id: p.id, internal_name: p.internal_name, name: p.name, description: p.description, type1: p.type1, type2: p.type2, hidden_ability: p.hidden_ability, regular_abilities: p.regular_abilities, evolution: p.evolution, growth_rate: p.growth_rate,  moves: fragment("array_agg(?)",m)}, group_by: p.id, where: ilike(p.name,^"%#{params["name"]}%") and ilike(m.name, ^"%#{params["move"]}%") and ilike(p.growth_rate, ^"%#{params["growth_rate"]}%") and (p.type1 == ^params["type1"] or p.type2 == ^params["type1"] or ^params["type1"] == "" )   and (p.type1 == ^params["type2"] or p.type2 == ^params["type2"] or ^params["type2"] == "" )        )
        sp = from(p in BaseStat, join: s in subquery(set), on: s.id == p.pokemon_id, select: %{id: s.id, name: s.name,description: s.description, internal_name: s.internal_name, type1: s.type1, type2: s.type2, hidden_ability: s.hidden_ability, regular_abilities: s.regular_abilities, evolution: s.evolution, growth_rate: s.growth_rate, moves: s.moves, atk: p."ATK", def: p."DEF", speed: p."SPEED", spd: p."Sp. DEF", spa: p."Sp. ATK", hp: p."HP" }, where: (ilike(s.hidden_ability, ^"%#{params["ability"]}%") or fragment("?=Any(regular_abilities)", ^"#{params["ability"]}") or ^params["ability"] == "") )
         mm = from(pl in PokemonLocation, join: l in Location, on: l.id == pl.location_id, right_join: s in subquery(sp), on: s.id == pl.pokemon_id, select: %{type1: s.type1, internal_name: s.internal_name, name: s.name, type2: s.type2, id: s.id, l: fragment("array_agg(?)", l.name)}, group_by: [s.internal_name, s.id, s.name, s.description, s.type1, s.type2, s.hidden_ability, s.regular_abilities, s.evolution, s.growth_rate, s.moves, s.atk, s.def, s.speed, s.spd, s.spa, s.hp], where: ilike(l.name,^"%#{params["location"]}%") or ^params["location"] == "", limit: 50)
        pokemons = Repo.all(mm)
        socket =
            socket
                |> assign(:pokemon_data, changeset)
                 |> assign(:pokemons, pokemons)
        {:noreply, socket}
    end
    def handle_event("test",%{"pname" => tes}, socket) do

      {:noreply,  push_redirect(socket, to: Routes.live_path(socket, PokemonLive, tes))}
    end


    def handle_event("reset",_, socket) do
      changeset = PokemonForm.changeset(%PokemonForm{})
      vv = from p in Pokemon,
      left_join: pl in PokemonLocation, on: p.id == pl.pokemon_id,
      left_join: l in Location, on: l.id == pl.location_id,
      select: %{type1: p.type1, type2: p.type2, id: p.id, name: p.name, l: fragment("array_agg(?)",l.name)},
      group_by: p.id, limit: 50
      pokemons = Repo.all(vv)
      socket =
        socket
          |> assign(:pokemon_data, changeset)
          |> assign(:pokemons, pokemons)
      {:noreply, socket}
    end
end
