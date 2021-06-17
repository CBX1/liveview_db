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
        group_by: p.id, limit: 200

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
      |> assign(:expand, false)


    {:ok, socket}
  end



  def handle_event("pokemon_new", %{"pokemon_form" => params}, socket) do
    changeset = PokemonForm.changeset(%PokemonForm{},params)
    set = from(p in Pokemon, as: :pkmn )
      |> set_q(params, "name")
      |> set_q(params, "type1")
      |> set_q(params, "type2")
      |> set_q(params, "growth_rate")
      |> set_q(params, "move")
    sp = from(p in BaseStat, join: s in subquery(set), on: s.id == p.pokemon_id, select: %{id: s.id, name: s.name,description: s.description, internal_name: s.internal_name, type1: s.type1, type2: s.type2, hidden_ability: s.hidden_ability, regular_abilities: s.regular_abilities, evolution: s.evolution, growth_rate: s.growth_rate, moves: s.moves, atk: p."ATK", def: p."DEF", speed: p."SPEED", spd: p."Sp. DEF", spa: p."Sp. ATK", hp: p."HP" })
      |> set_sq(params,"hidden_ability")
      |> set_sq(params, "regular_abilities")
     mm = from(pl in PokemonLocation)
          |> set_mm(sp,params,"location")
    pokemons = Repo.all(mm)
    socket =
        socket
            |> assign(:pokemon_data, changeset)
             |> assign(:pokemons, pokemons)
    {:noreply, socket}
end

def set_mm(query, sp, params, check) do
  cond do
    check == "location" ->
      if params["location"] != nil do
        from(pl in query, join: l in Location, on: l.id == pl.location_id, right_join: s in subquery(sp), on: s.id == pl.pokemon_id, select: %{type1: s.type1, internal_name: s.internal_name, name: s.name, type2: s.type2, id: s.id, l: fragment("array_agg(?)", l.name)}, group_by: [s.internal_name, s.id, s.name, s.description, s.type1, s.type2, s.hidden_ability, s.regular_abilities, s.evolution, s.growth_rate, s.moves, s.atk, s.def, s.speed, s.spd, s.spa, s.hp], where: ilike(l.name,^"%#{params["location"]}%"), limit: 50, order_by: s.id)
      else
        from(pl in query, join: l in Location, on: l.id == pl.location_id, right_join: s in subquery(sp), on: s.id == pl.pokemon_id, select: %{type1: s.type1, internal_name: s.internal_name, name: s.name, type2: s.type2, id: s.id, l: fragment("array_agg(?)", l.name)}, group_by: [s.internal_name, s.id, s.name, s.description, s.type1, s.type2, s.hidden_ability, s.regular_abilities, s.evolution, s.growth_rate, s.moves, s.atk, s.def, s.speed, s.spd, s.spa, s.hp], limit: 50, order_by: s.id)
      end

  end
end
def set_sq(query, params, check) do
  cond do
    check == "hidden_ability" ->
      if params["hidden_ability"] != nil do
        from(s in query, where: ilike(s.hidden_ability, ^"%#{params["ability"]}%"))
      else
        query
      end
    check == "regular_abilities" ->
      if params["regular_abilities"] != nil do
        from(s in query, where: fragment("?=Any(regular_abilities)", ^"#{params["ability"]}"))
      else
        query
      end
  end
end

def set_q(query,params,check) do
  cond do
    check == "name" ->
      if params["name"] != nil do
        from(p in query, where: ilike(p.name,^"%#{params["name"]}%") )
      else
        query
      end
    check == "growth_rate" ->
       if params["growth_rate"] != nil do
          from(p in query, where: ilike(p.growth_rate,^"%#{params["growth_rate"]}%") )
        else
          query
        end
    check == "move" ->
      if params["move"] != nil do
        from(p in query, join: m in Move, where: ilike(m.name, ^"%#{params["move"]}%"),select: %{id: p.id, internal_name: p.internal_name, name: p.name, description: p.description, type1: p.type1, type2: p.type2, hidden_ability: p.hidden_ability, regular_abilities: p.regular_abilities, evolution: p.evolution, growth_rate: p.growth_rate, moves: fragment("array_agg(?)",m)}, group_by: p.id )
      else
        from(p in query, join: m in Move, select: %{id: p.id, internal_name: p.internal_name, name: p.name, description: p.description, type1: p.type1, type2: p.type2, hidden_ability: p.hidden_ability, regular_abilities: p.regular_abilities, evolution: p.evolution, growth_rate: p.growth_rate, moves: fragment("array_agg(?)",m)}, group_by: p.id )
      end
    check == "type1" ->
      if params["type1"] != nil do
        from(p in query, where: ilike(p.type1, ^"%#{params["type1"]}%") or ilike(p.type2, ^"%#{params["type1"]}%"))
      else
        query
      end
    check == "type2" ->
      if params["type2"] != nil do
          from(p in query, where: ilike(p.type1g, ^"%#{params["type2"]}%") or ilike(p.type2, ^"%#{params["type2"]}%") )
      else
        query
      end
    end
end
def handle_event("test",%{"pname" => tes}, socket) do

  {:noreply,  push_redirect(socket, to: Routes.live_path(socket, PokemonLive, tes))}
end


    def handle_event("reset",_, socket) do
      changeset = PokemonForm.changeset(%PokemonForm{})
      vv = from p in Pokemon,
      left_join: pl in PokemonLocation, on: p.id == pl.pokemon_id,
      left_join: l in Location, on: l.id == pl.location_id,
      select: %{type1: p.type1, type2: p.type2, internal_name: p.internal_name, id: p.id, name: p.name, l: fragment("array_agg(?)",l.name)},
      group_by: p.id, limit: 200
      pokemons = Repo.all(vv)
      socket =
        socket
          |> assign(:pokemon_data, changeset)
          |> assign(:pokemons, pokemons)
      {:noreply, socket}
    end


    def handle_event("adv_search",%{"bool" => bool}, socket) do

        IO.inspect bool
        if bool == "false" do
          socket = socket |> assign(:expand, true)
        {:noreply, socket}
        else
          socket = socket |> assign(:expand, false)
          {:noreply, socket}
        end

    end

end
