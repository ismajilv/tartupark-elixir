defmodule Tartupark.BookingAPIController do
  use Tartupark.Web, :controller
  import Ecto.Query, only: [from: 2]
  alias Tartupark.{Place, Booking}

  Postgrex.Types.define(Tartupark.PostgresTypes,
  [Geo.PostGIS.Extension] ++ Ecto.Adapters.Postgres.extensions(),
  json: Poison)

  def create(conn, %{"parking_address" => [params]}) do
    user = Guardian.Plug.current_resource(conn)
    %{
       "area" => area,
       "capacity" => capacity,
       "distance" => distance,
       "id" => place_id,
       "parkingStartTime" => parkingStartTime,
       "parkingEndTime" => parkingEndTime,
       "parkingSearchRadius" => parkingSearchRadius,
       "paymentTime" => paymentTime,
       "paymentType" => paymentType,
       "shape" => shape,
       "zone" => %{"zone_id" => zone_id}
     } = params

     start_time = parseToNaiveDateTime(parkingStartTime)
     case paymentType do
         "Hourly" -> end_time = parseToNaiveDateTime(parkingEndTime)
         _        -> end_time = nil
     end
     booking_params = %{startDateTime: start_time, endDateTime: end_time, paymentTime: paymentTime, paymentType: paymentType}
     booking_place_bind = Ecto.build_assoc(Repo.get(Place, place_id), :bookings, booking_params)
     booking = Ecto.build_assoc(user, :bookings, booking_place_bind)
               |> Repo.insert!

    conn
    |> put_status(201)
    |> json(%{msg: "Booking has been done.", booking_id: booking.id})
  end

  def update(conn, _params) do
    conn
    |> put_status(200)
    |> json(%{msg: "Notification sent to the custome"})
  end

  def search(conn, params) do
    %{"lngLat" => %{"lat" => lat, "lng" => lng}} =  params
    point = %Geo.Point{coordinates: {lng, lat}, srid: 4326}
    radius = Regex.run(~r/\d+/, params["parkingSearchRadius"]) |> List.first |> Integer.parse |> elem(0)
    parkings = Place.within(Place, point, radius)
    |> Place.order_by_nearest(point)
    |> Place.select_with_distance(point)
    |> Repo.all
    |> Repo.preload(:zone)

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

  def parseToNaiveDateTime(dateTime) do
    scannedDateTime = Regex.scan(~r/\d+/, dateTime, trim: true)
    |> List.flatten
    |> Enum.map(fn calendarElem -> Integer.parse(calendarElem) |> elem(0)  end)
    [year, month, day, hour, minute, second, microsecond] = scannedDateTime
    NaiveDateTime.new(year, month, day, hour, minute, second, microsecond) |> elem(1)
  end
end
