defmodule PokemonDbWeb.AbilityLive do
  use PokemonDbWeb, :live_view
  import Ecto.Query
  alias PokemonDb.Repo
  alias PokemonDb.Ability

  def mount(_params, _session, socket) do
    socket = socket |> assign(:main_data, nil)
    {:ok, socket}
  end

  def handle_params(params, _uri, socket) do
    var = params["ability"]
    |> String.replace(" ", "")
    |> String.replace("-", "")
    |> String.replace("'", "")
    |> String.upcase

    a = Repo.all(from m in Ability, where: m.name == ^params["ability"], select: m) |> hd
    IO.inspect a
    socket = socket |> assign(:main_data, a)
    {:noreply, socket}
  end

end
