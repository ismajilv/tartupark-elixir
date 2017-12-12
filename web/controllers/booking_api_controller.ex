defmodule Tartupark.BookingAPIController do
  use Tartupark.Web, :controller
  import Ecto.Query, only: [from: 2]
  alias Tartupark.{Place, Booking, User}

  Postgrex.Types.define(Tartupark.PostgresTypes,
  [Geo.PostGIS.Extension] ++ Ecto.Adapters.Postgres.extensions(),
  json: Poison)

  def index(conn, _params) do

    user = Guardian.Plug.current_resource(conn)
    query = from booking in Booking,
            join: user in User, on: booking.user_id == user.id,
            select: booking
    booking = Repo.all(query)
    conn
    |> put_status(201)
    |> json(%{msg: "Bookings are available.", bookings: booking})
  end

  def create(conn,  params) do

    user = Guardian.Plug.current_resource(conn)
    %{
       "id" => place_id,
       "parkingStartTime" => parkingStartTime,
       "parkingEndTime" => parkingEndTime,
       "paymentTime" => paymentTime,
       "paymentType" => paymentType
     } = params["parking_address"]


     start_time = parseToNaiveDateTime(parkingStartTime)
     case paymentType do
         "Hourly" -> end_time = parseToNaiveDateTime(parkingEndTime)
          _       -> end_time = nil
     end
     booking_params = %{startDateTime: start_time, endDateTime: end_time, paymentTime: paymentTime, paymentType: paymentType}
     booking_place_bind = Ecto.build_assoc(Repo.get(Place, place_id), :bookings, booking_params)
     booking = Ecto.build_assoc(user, :bookings, booking_place_bind)
               |> Repo.insert!

    case Map.get(Map.get(params, "paymentParams"), "cost") do
       nil     -> payment_id = nil
       payment -> cost = payment |> Float.parse |> elem(0)
                  payment_id = Tartupark.PaymentAPIController.create(conn, %{"bookingId" => booking.id, "cost" => cost})
    end

    conn
    |> put_status(201)
    |> json(%{msg: "Booking has been done.", booking_id: booking.id})
  end

  def update(conn, %{"booking_id" => booking_id, "parkingEndTime" => end_time}) do
    booking = Repo.get!(Booking, booking_id)
    changeset = Booking.changeset(booking, endTime: parseToNaiveDateTime(end_time))
    case Booking.update changeset do
      {:ok, _struct}       -> conn
                             |> put_status(200)
                             |> json(%{msg: "Booking parameters successfully updated"})
      {:error, _changeset} -> conn
                             |> put_status(400)
                             |> json(%{msg: "Booking parameters were not updated"})
    end
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

    start_time = parseToNaiveDateTime(params["parkingStartTime"])
    end_time = parseToNaiveDateTime(params["parkingEndTime"])

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
                                                   case checkBetweenOrAfter(start_time, end_time, book.startDateTime, book.endDateTime) do
                                                     true -> capacity-1
                                                     false -> capacity
                                                   end
                                                 end),
                            parkingStartTime: start_time,
                            parkingEndTime: end_time,
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



  def parseToNaiveDateTime(dateTime) when dateTime != nil do
    scannedDateTime = Regex.scan(~r/\d+/, dateTime, trim: true)
    |> List.flatten
    |> Enum.map(fn calendarElem -> Integer.parse(calendarElem) |> elem(0)  end)
    case length(scannedDateTime) do
       6 -> [year, month, day, hour, minute, second] = scannedDateTime
       7 -> [year, month, day, hour, minute, second, _millisecond] = scannedDateTime
       8 -> [year, month, day, hour, minute, second, _timezone1, _timesone2] = scannedDateTime
    end
    NaiveDateTime.new(year, month, day, hour, minute, second) |> elem(1)
  end
  def parseToNaiveDateTime(dateTime), do: nil




  def checkBetweenOrAfter(start_1, end_1, start_2, end_2) do
    case {start_1, end_1, start_2, end_2} do
      {st1, nil, st2, nil} ->                                 true
      {st1, nil, st2, ed2} when ed2 != nil ->                 NaiveDateTime.compare(NaiveDateTime.add(ed2, -120), st1) == :gt

      {st1, ed1, st2, nil} when ed1 != nil ->                 NaiveDateTime.compare(ed1, st2) == :gt or
                                                              NaiveDateTime.compare(ed1, st2) == :eq

      {st1, ed1, st2, ed2} when ed1 != nil and ed2 != nil -> not ((NaiveDateTime.compare(st1, st2) == :lt   and
                                                                   NaiveDateTime.compare(ed1, st2) == :lt)  or
                                                                   NaiveDateTime.compare(NaiveDateTime.add(ed2, -120), st1) == :lt)

       _ ->                                                   false
    end
  end
end
