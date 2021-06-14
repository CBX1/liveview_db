defmodule PokemonDb.Repo do
  use Ecto.Repo,
    otp_app: :pokemon_db,
    adapter: Ecto.Adapters.Postgres
end
