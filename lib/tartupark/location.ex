defmodule Tartupark.Location do
  use Ecto.Schema
  import Ecto.Changeset
  alias Tartupark.Location


  schema "locations" do
    field :lat, :float
    field :long, :float
    field :status, :string
    field :type, :string

    timestamps()
  end

  @doc false
  def changeset(%Location{} = location, attrs) do
    location
    |> cast(attrs, [:lat, :long, :status, :type])
    |> validate_required([:lat, :long, :status, :type])
  end
end
