defmodule Tartupark.BookingAPIController do
  use Tartupark.Web, :controller
  import Ecto.Query, only: [from: 2]
  alias Tartupark.Place

  Postgrex.Types.define(Tartupark.PostgresTypes,
  [Geo.PostGIS.Extension] ++ Ecto.Adapters.Postgres.extensions(),
  json: Poison)

  def create(conn, _params) do
      conn
      |> put_status(201)
      |> json(%{msg: "We are processing your request"})
  end

  def update(conn, _params) do
    conn
    |> put_status(200)
    |> json(%{msg: "Notification sent to the customer"})
  end

  def search(conn, params) do
    %{"lngLat" => %{"lat" => lat, "lng" => lng}} =  params
    point = %Geo.Point{coordinates: {lng, lat}, srid: 4326}
    radius = Regex.run(~r/\d+/, params["parkingSearchRadius"]) |> List.first |> Integer.parse |> elem(0)
    parkings = Place.within(Place, point, radius)
    |> Place.order_by_nearest(point)
    |> Place.select_with_distance(point)
    |> Repo.all
    |> Repo.preload :zone

    # IO.inspect parkings

    locations = Enum.map(parkings,
                        (fn park_place ->
                          %{shape: park_place.shape,
                            capacity: park_place.capacity,
                            distance: park_place.distance,
                            id: park_place.id,
                            area: Enum.map(park_place.area.coordinates,
                                           fn point -> {lng, lat} = point
                                              %{lng: lng, lat: lat}
                                           end),
                            zone:  %{
                                      costHourly: park_place.zone.costHourly,
                                      costRealTime: park_place.zone.costRealTime,
                                      description: park_place.zone.description,
                                      freeTimeLimit: park_place.zone.freeTimeLimit,
                                      zone_id: park_place.zone.id,
                                      tag: park_place.zone.tag
                                    },
                            parkingStartTime: params["parkingStartTime"],
                            parkingEndTime: params["parkingEndTime"],
                            parkingSearchRadius: params["parkingSearchRadius"],
                            paymentTime: params["paymentTime"],
                            paymentType: params["paymentType"]
                          }
                          end))
    conn
    |> put_status(200)
    |> json(locations)
  end
end
