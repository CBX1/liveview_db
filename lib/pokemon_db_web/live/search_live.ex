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
        select: %{type1: p.type1, type2: p.type2, id: p.id, internal_name: p.internal_name, name: p.name},
        order_by: p.id, limit: 200

    yy = from wr in Pokemon, select: %{regular: wr.hidden_ability}, distinct: wr.hidden_ability
    q = from(a in Pokemon, select: %{ability: fragment("unnest(?)", a.regular_abilities)}, distinct: true )
    qq = from(b in subquery(q), union: ^yy, distinct: true)
    o = from(g in subquery(qq), select: g.ability, order_by: g.ability)
    growth_rate = ["Fluctuating","Erratic","Slow","Fast","Medium","Parabolic"]
    location_query =  from n in Location, select: n.name, distinct: n.name, order_by: n.name
    locations = Repo.all(location_query)
    pokemons = Repo.all(vv)
    # Polaris, Calvera, All
    abilities = Repo.all(o) |> tl
    type_query = from p in Pokemon, select: p.type1, distinct: p.type1
    types = Repo.all(type_query)
    socket =
      socket
      |> assign(:pokemon_data, PokemonForm.changeset(%PokemonForm{}))
      |> assign(:pokemons, pokemons)
      |> assign(:abilities, abilities)
      |> assign(:growth_rate, growth_rate)
      |> assign(:location, locations)
      |> assign(:types, types)
      |> assign(:expand, false)


    {:ok, socket}
  end



  def handle_event("pokemon_new", %{"pokemon_form" => params}, socket) do
    changeset = PokemonForm.changeset(%PokemonForm{},params)
    # if (params["ability"] == "" && params["growth_rate"] == "" && params["name"] == "" && params["type1"] == "" && params["type2"] == "" && params["location"] == "") do
    #   vv = from p in Pokemon,
    #   select: %{type1: p.type1, type2: p.type2, id: p.id, internal_name: p.internal_name, name: p.name},
    #   group_by: p.id
    #   pokemons = Repo.all(vv)
    #   socket =
    #   socket
    #       |> assign(:pokemon_data, changeset)
    #        |> assign(:pokemons, pokemons)
    # else
      set = from(p in Pokemon, as: :pkmn )
        |> set_q(params, "name")
        |> set_q(params, "type1")
        |> set_q(params, "type2")
        |> set_q(params, "growth_rate")
        |> set_q(params, "ability")
        |> set_q(params, "location")
        # mm = from(set in PokemonLocation)
        #       |> set_mm(set,params,"location")
        pokemons = Repo.all(set)
        # IO.inspect pokemons
        socket =
            socket
                |> assign(:pokemon_data, changeset)
                |> assign(:pokemons, pokemons)
    # end
    {:noreply, socket}
end



def set_q(query,params,check) do
  cond do
    check == "location" ->
      if params["location"] != ""  && !is_nil(params["location"])  do
        # IO.inspect "check?"
        from(p in query, join: pl in PokemonLocation, on: pl.pokemon_id == p.id, join: l in Location, on: l.id == pl.location_id, where: l.name == ^params["location"], select: p, limit: 200)
      else
        from(p in query, limit: 200)
    end
    check == "ability" ->
      if params["ability"] != "" && !is_nil(params["ability"])  do
        from(p in query, where: ilike(p.hidden_ability,^"%#{params["ability"]}%") or fragment("?=ANY(regular_abilities)",^params["ability"]) )
      else
        query
      end
    check == "name" ->
      if params["name"] != ""   && !is_nil(params["name"]) do
        from(p in query, where: ilike(p.name,^"%#{params["name"]}%") )
      else
        query
      end
    check == "growth_rate" ->
       if params["growth_rate"] != "" &&  !is_nil(params["growth_rate"])  do
          from(p in query, where: ilike(p.growth_rate,^"%#{params["growth_rate"]}%") )
        else
          query
        end
    check == "type1" ->
      if params["type1"] != "" && !is_nil(params["type1"])  do
        from(p in query, where: ilike(p.type1, ^"%#{params["type1"]}%") or ilike(p.type2, ^"%#{params["type1"]}%"))
      else
        query
      end
    check == "type2" ->
      if params["type2"] != "" && !is_nil(params["type2"]) do
          from(p in query, where: ilike(p.type1, ^"%#{params["type2"]}%") or ilike(p.type2, ^"%#{params["type2"]}%") )
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
      select: %{type1: p.type1, type2: p.type2, internal_name: p.internal_name, id: p.id, name: p.name},
      order_by: p.id, limit: 200
      pokemons = Repo.all(vv)
      socket =
        socket
          |> assign(:pokemon_data, changeset)
          |> assign(:pokemons, pokemons)
      {:noreply, socket}
    end


    def handle_event("adv_search",%{"bool" => bool}, socket) do

        # IO.inspect bool
        if bool == "false" do
          socket = socket |> assign(:expand, true)
        {:noreply, socket}
        else
          socket = socket |> assign(:expand, false)
          {:noreply, socket}
        end

    end

end
