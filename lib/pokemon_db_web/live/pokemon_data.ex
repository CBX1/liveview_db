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

  }
  def mount(_params, _session, socket) do
    socket = socket |> assign(:namee, "") |> assign(:main_data, "") |> assign(:moves, "") |> assign(:locations, nil)
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
    if params["pokemon"] == "NIDORANfE" || params["pokemon"] == "NIDORANmA" do
      mm = from p in Pokemon, left_join: pl in PokemonLocation, on: pl.pokemon_id == p.id, left_join: l in Location,
      on: l.id == pl.location_id, select: [p, fragment("ARRAY_AGG(?)",l.name)], group_by: p.id, where: p.internal_name == ^params["pokemon"]
      pokemons = Repo.all(mm)
      socket = socket |> assign(:main_data, pokemons |> hd |> hd) |> assign(:locations, pokemons |> hd |> tl |> hd) #|> assign(:moves, movs)
      {:noreply, socket}

    else
      var = params["pokemon"] |> String.upcase
      mm = from p in Pokemon, left_join: pl in PokemonLocation, on: pl.pokemon_id == p.id, left_join: l in Location,
      on: l.id == pl.location_id, select: [p, fragment("ARRAY_AGG(?)",l.name)], group_by: p.id, where: p.internal_name == ^var

      pokemons = Repo.all(mm)
      socket = socket |> assign(:main_data, pokemons |> hd |> hd) |> assign(:locations, pokemons |> hd |> tl |> hd) #|> assign(:moves, movs)
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
