defmodule Tartupark.Place do
  use Tartupark.Web, :model

  schema "places" do
    field :area, Geo.MultiPoint
    field :capacity, :integer
    field :status, :string, default: "available"
    field :distance, :float, virtual: true
    belongs_to :zone, Tartupark.Zone
    timestamps()
  end

  @doc """
  Builds a changeset based on the `struct` and `params`.
  """
  def changeset(struct, params \\ %{}) do
    struct
    |> cast(params, [:area, :capacity, :status])
    |> validate_required([:area, :capacity])
  end

  def within(query, point, radius_in_m) do
    {lng, lat} = point.coordinates
    from(parking in query, where: fragment("ST_DWithin(?::geography, ST_SetSRID(ST_MakePoint(?, ?), ?), ?)", parking.geom, ^lng, ^lat, ^point.srid, ^radius_in_m))
  end

  #Orders all the polygons of the db by nearest from the given point
  def order_by_nearest(query, point) do
    {lng,lat} = point.coordinates
    from(parking in query, order_by: fragment("? <-> ST_SetSRID(ST_MakePoint(?,?), ?)", parking.geom, ^lng,^lat , ^point.srid))
  end

  #Return all the parkings with the distances between the polygons points and the given point
  def select_with_distance(query, point) do
    {lng,lat} = point.coordinates
    from(parking in query,
      select: %{parking | distance: fragment("ST_Distance_Sphere(?, ST_SetSRID(ST_MakePoint(?,?), ?))", parking.geom, ^lng, ^lat, ^point.srid)})
  end

  # point = %Geo.Point{coordinates: {58.365758, 26.690846}, srid: 4326}
  #     radius = 5000
  #     parkings = TartuParking.Parking.within(Parking, point, radius)
  #     |> TartuParking.Parking.order_by_nearest(point)
  #     |> TartuParking.Parking.select_with_distance(point)
  #     |> Repo.all
  #     IO.inspect parkings
end
