defmodule Tartupark.Zone do
  use Tartupark.Web, :model

  schema "zones" do
    field :name, :string
    field :costHourly, :float
    field :costRealTime, :float
    field :busFree, :boolean, default: false
    field :motoFree, :boolean, default: false
    has_many :places, Tartupark.Place

    timestamps()
  end

  @doc """
  Builds a changeset based on the `struct` and `params`.
  """
  def changeset(struct, params \\ %{}) do
    struct
    |> cast(params, [:name, :costHourly, :costRealTime, :busFree, :motoFree])
    |> validate_required([:name, :costHourly, :costRealTime, :busFree, :motoFree])
  end

end
