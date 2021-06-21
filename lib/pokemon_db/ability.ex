defmodule PokemonDb.Ability do
  use Ecto.Schema
  import Ecto.Changeset

  schema "abilities" do
    field :internal_name, :string
    field :name, :string
    field :description, :string

  end

  @doc false
  def changeset(ability, params \\ %{}) do
    ability
    |> change(params)
    |> validate_required([:name])
  end
end
