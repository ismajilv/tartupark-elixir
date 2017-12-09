defmodule Tartupark.BookingAPIController do
  use Tartupark.Web, :controller
  import Ecto.Query, only: [from: 2]
  alias Tartupark.{Place, Booking}

  Postgrex.Types.define(Tartupark.PostgresTypes,
  [Geo.PostGIS.Extension] ++ Ecto.Adapters.Postgres.extensions(),
  json: Poison)

  def create(conn, %{"parking_address" => [params]}) do

    IO.inspect "*********************"
    IO.inspect params
    IO.inspect "*********************"

    user = Guardian.Plug.current_resource(conn)
    %{
       "id" => place_id,
       "parkingStartTime" => parkingStartTime,
       "parkingEndTime" => parkingEndTime,
       "paymentTime" => paymentTime,
       "paymentType" => paymentType
     } = params

     start_time = parseToNaiveDateTime(parkingStartTime)
     case paymentType do
         "Hourly" -> end_time = parseToNaiveDateTime(parkingEndTime)
          _       -> end_time = nil
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
    |> Repo.preload([:zone, :bookings])

    locations = Enum.map(parkings,
                        (fn park_place ->
                          %{shape: park_place.shape,
                            # capacity: park_place.capacity,
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
                            capacity: List.foldl(park_place.bookings,
                                                 park_place.capacity,
                                                 fn (book, capacity) ->
                                                   case checkBetweenOrAfter(params["parkingStartTime"], params["parkingEndTime"], book.startDateTime, book.endDateTime) do
                                                     true -> capacity-1
                                                     false -> capacity
                                                   end
                                                 end),
                            parkingStartTime: params["parkingStartTime"],
                            parkingEndTime: params["parkingEndTime"],
                            parkingSearchRadius: params["parkingSearchRadius"],
                            paymentTime: params["paymentTime"],
                            paymentType: params["paymentType"]
                          }
                          end))

    locations = Enum.filter(locations, fn loc -> loc.capacity > 0 end)
    # IO.inspect locations
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

  def checkBetweenOrAfter(start_1, end_1, start_2, end_2) do
    case {start_1, end_1, start_2, end_2} do
      {st1, nil, st2, nil} ->  true
      {st1, nil, st2, ed2} when ed2 != nil -> (NaiveDateTime.compare(parseToNaiveDateTime(st1), st2) == :gt   or
                                               NaiveDateTime.compare(parseToNaiveDateTime(st1), st2) == :eq)  and
                                               NaiveDateTime.compare(ed2, parseToNaiveDateTime(st1)) == :lt
      {st1, ed1, st2, nil} when ed1 != nil ->  NaiveDateTime.compare(parseToNaiveDateTime(ed1), st2) == :gt   or
                                               NaiveDateTime.compare(parseToNaiveDateTime(ed1), st2) == :eq
      {st1, ed1, st2, ed2} ->                 (NaiveDateTime.compare(parseToNaiveDateTime(st1), st2) == :gt   or
                                               NaiveDateTime.compare(parseToNaiveDateTime(st1), st2) == :eq) and
                                              (NaiveDateTime.compare(ed2, parseToNaiveDateTime(ed1)) == :gt   or
                                               NaiveDateTime.compare(ed2, parseToNaiveDateTime(ed1)) == :eq)
    end
  end
# "parkingEndTime" => "Invalid dateZ"
end
