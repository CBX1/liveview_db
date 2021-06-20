defmodule PokemonDbWeb.MoveLive do
  use PokemonDbWeb, :live_view
import Ecto.Query
alias PokemonDb.MoveList
alias PokemonDb.Repo
  def mount(_params, _session, socket) do
    socket = socket
                |> assign(:move, nil)
    {:ok, socket}
  end
  def handle_params(params, _uri, socket) do
    IO.inspect params
    var = params["move"]
            |> String.replace(" ", "")
            |> String.replace("-", "")
            |> String.replace("'", "")
            |> String.upcase
    a = Repo.all(from m in MoveList, where: m.name == ^var, select: m) |> hd
    socket = socket
                |> assign(:move, a)
    {:noreply, socket}

  end
end
