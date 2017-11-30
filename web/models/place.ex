defmodule Tartupark.Place do
  use Tartupark.Web, :model

  schema "places" do
    field :latitude, :float
    field :longitude, :float
    field :capacity, :integer
    field :status, :string, default: "available"
    belongs_to :zone, Tartupark.Zone
    timestamps()
  end

  @doc """
  Builds a changeset based on the `struct` and `params`.
  """
  def changeset(struct, params \\ %{}) do
    struct
    |> cast(params, [:latitude, :longitude, :capacity, :status])
    |> validate_required([:latitude, :longitude, :capacity])
  end

end
