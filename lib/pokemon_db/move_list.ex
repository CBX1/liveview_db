defmodule PokemonDb.MoveList do
  use Ecto.Schema
  import Ecto.Changeset

  schema "move_list" do
    field :name, :string
    field :moves, {:array, :integer}
    field :internal_name, :string
    field :power, :id
    field :description, :string
    field :forc, :string
    field :type, :string
    field :acc, :id
    field :basepp, :id
    field :additional_effect, :integer
    field :target, :integer
    field :priority, :integer
    field :al_code, :string

  end

  @doc false
  def changeset(move_list, attrs \\ %{}) do
    move_list
    |> change(attrs)
    |> validate_required([:name])
    |> unique_constraint([:name])
  end
end
