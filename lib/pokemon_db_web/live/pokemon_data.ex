defmodule PokemonDbWeb.PokemonLive do
  use PokemonDbWeb, :live_view
  import Ecto.Query
  import Ecto.Changeset
  alias PokemonDbWeb.Router.Helpers, as: Routes
  alias PokemonDbWeb.SearchLive
  alias PokemonDbWeb.MoveLive
  alias PokemonDbWeb.AbilityLive
  alias PokemonDb.{
    Repo,
    Pokemon,
    PokemonLocation,
    Location,
    Move,
    BaseStat,
    PokemonForm,
    MoveList,
    Ability

  }
  def mount(_params, _session, socket) do
    socket = socket |> assign(:typeChart, "") |> assign(:namee, "") |> assign(:main_data, "") |> assign(:moves, "") |> assign(:locations, nil)
    {:ok, socket}
  end

  def handle_params(%{"name" => id} = _params, _uri, socket) do


    socket = socket |> assign(:namee, id)
    {:noreply, socket}
  end

  def handle_event("home",params, socket) do


    {:noreply,  push_redirect(socket, to: Routes.live_path(socket, SearchLive, params))}
  end


  def twoType(a, nil) do
    typeAdvantage(a)
end

def twoType(a,b) do
    Map.merge(typeAdvantage(a), typeAdvantage(b), fn _k, v1, v2 ->
        v1 * v2
      end )
end

def typeAdvantage(type) do
    cond do
        type == "NORMAL" ->
            fillinBlanks(%{FIGHTING: 2.0, GHOST: 0})
        type == "FIRE" ->
            fillinBlanks(%{FIRE: 0.5, WATER: 2.0, GRASS: 0.5, ICE: 0.5, GROUND: 2.0, BUG: 0.5, ROCK: 2.0, STEEL: 0.5, FAIRY: 0.5})
        type == "WATER" ->
            fillinBlanks(%{FIRE: 0.5, WATER: 0.5, GRASS: 2.0, ELECTRIC: 2.0, ICE: 0.5, STEEL: 0.5})
        type == "ELECTRIC" ->
            fillinBlanks(%{ELECTRIC: 0.5, GROUND: 2.0, FLYING: 0.5, STEEL: 0.5})
        type == "GRASS" ->
            fillinBlanks(%{FIRE: 2.0, WATER: 0.5, ELECTRIC: 0.5, GRASS: 0.5, ICE: 2.0, GROUND: 0.5, FLYING: 2.0, BUG: 2.0})
        type == "ICE" ->
            fillinBlanks(%{FIRE: 2.0, ICE: 0.5, FIGHTING: 2.0, ROCK: 2.0, STEEL: 2.0})
        type == "FIGHTING" ->
            fillinBlanks(%{FLYING: 2.0, PSYCHIC: 2.0, BUG: 0.5, ROCK: 0.5, DARK: 0.5, FAIRY: 2.0})
        type == "POISON" ->
            fillinBlanks(%{POISON: 0.5, GRASS: 0.5, FIGHTING: 0.5, GROUND: 2, PSYCHIC: 2, BUG: 0.5, FAIRY: 0.5 })
        type == "GROUND" ->
            fillinBlanks(%{WATER: 2.0, ELECTRIC: 0, GRASS: 2.0, ICE: 2.0, POISON: 0.5, ROCK: 0.5})
        type == "FLYING" ->
            fillinBlanks(%{ELECTRIC: 2.0, GRASS: 0.5, ICE: 2.0, FIGHTING: 0.5, GROUND: 0, BUG: 0.5, ROCK: 2.0})
        type == "PSYCHIC" ->
            fillinBlanks(%{FIGHTING: 0.5, PSYCHIC: 0.5, BUG: 2.0, GHOST: 2.0, DARK: 2.0})
        type == "BUG" ->
            fillinBlanks(%{FIRE: 2.0, GRASS: 0.5, FIGHTING: 0.5, GROUND: 0.5, FLYING: 2.0, ROCK: 2.0})
        type == "STEEL" ->
            fillinBlanks(%{NORMAL: 0.5, FIRE: 2.0, GRASS: 0.5, ICE: 0.5, FIGHTING: 2.0, POISON: 0, GROUND: 2.0, FLYING: 0.5, ROCK: 0.5, PSYCHIC: 0.5, BUG: 0.5, DRAGON: 0.5, STEEL: 0.5, FAIRY: 0.5})
        type == "FAIRY" ->
            fillinBlanks(%{FIGHTING: 0.5, POISON: 2.0, DRAGON: 0, DARK: 0.5, GHOST: 0.5, STEEL: 2.0})
        type == "GHOST" ->
            fillinBlanks(%{NORMAL: 0, FIGHTING: 0, POISON: 0.5, BUG: 0.5, GHOST: 2, DARK: 2})
        type == "ROCK" ->
          fillinBlanks(%{NORMAL: 0.5, WATER: 2.0, GRASS: 2.0, FIRE: 0.5, STEEL: 2.0, FIGHTING: 2.0, FLYING: 0.5, POISON: 0.5})
        type == "DARK" ->
          fillinBlanks(%{BUG: 2.0, FIGHTING: 2.0, PSYCHIC: 0, FAIRY: 2.0, GHOST: 0.5, DARK: 0.5})
        type == "DRAGON" ->
          fillinBlanks(%{ICE: 2.0, GRASS: 0.5, WATER: 0.5, FIRE: 0.5, FAIRY: 2.0, DRAGON: 2.0})
    end
end

def fillinBlanks(typearr) do
    map = %{NORMAL: 1.0, FIRE: 1.0, WATER: 1.0,
        ELECTRIC: 1.0, GRASS: 1.0, ICE: 1.0,
        POISON: 1.0, GROUND: 1.0, FLYING: 1.0,
        PSYCHIC: 1.0, BUG: 1.0, ROCK: 1.0,
        GHOST: 1.0, DRAGON: 1.0, DARK: 1.0,
        STEEL: 1.0, FAIRY: 1.0, FIGHTING: 1.0}
  Map.merge(typearr, map, fn _k, v1, v2 ->
    v1
  end )


end


  def handle_params(params, _uri, socket) do
     IO.inspect params
    if params["pokemon"] == "NIDORANfE" || params["pokemon"] == "NIDORANmA" do
      mm = from p in Pokemon, left_join: pl in PokemonLocation, on: pl.pokemon_id == p.id, left_join: l in Location,
      on: l.id == pl.location_id, select: [p, fragment("ARRAY_AGG(?)",l.name)], group_by: p.id, where: p.internal_name == ^params["pokemon"]
      pokemons = Repo.all(mm)
      on = pokemons |> hd |> hd
       typechart = twoType(on.type1, on.type2)
      socket = socket |> assign(:typeChart, typechart) |> assign(:main_data, pokemons |> hd |> hd) |> assign(:locations, pokemons |> hd |> tl |> hd) #|> assign(:moves, movs)
      {:noreply, socket}

    else
      var = params["pokemon"] |> String.upcase
      mm = from p in Pokemon, left_join: pl in PokemonLocation, on: pl.pokemon_id == p.id, left_join: l in Location,
      on: l.id == pl.location_id, select: [p, fragment("ARRAY_AGG(?)",l.name)], group_by: p.id, where: p.internal_name == ^var

      pokemons = Repo.all(mm)
      on = pokemons |> hd |> hd
      typechart = twoType(on.type1, on.type2)
      socket = socket |> assign(:typeChart, typechart) |> assign(:main_data, pokemons |> hd |> hd) |> assign(:locations, pokemons |> hd |> tl |> hd) #|> assign(:moves, movs)
      {:noreply, socket}
    end


    # movs = (pokemons |> hd).moves |> Enum.flatten

  end


  def handle_event("test",%{"pname" => tes}, socket) do

    {:noreply,  push_redirect(socket, to: Routes.live_path(socket, PokemonDbWeb.PokemonLive, tes))}
  end

  def handle_event("moverr", params, socket) do
    a = %{move: params["movedata"]}
    {:noreply,  push_redirect(socket, to: Routes.live_path(socket, MoveLive, params["movedata"]))}
  end

  def handle_event("click_ability", params, socket) do
    {:noreply, push_redirect(socket, to: Routes.live_path(socket, AbilityLive, params["ability"]))}
  end
end
