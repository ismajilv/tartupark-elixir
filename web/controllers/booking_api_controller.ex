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
    bookings = Repo.all(query) |> Repo.preload([:payment, place: [:zone]])

    bookings = bookings
    |> Enum.map(fn book ->
                  %{startDateTime: book.startDateTime,
                    endDateTime: book.endDateTime,
                    booking_id: book.id,
                    inserted_at: book.inserted_at,
                    paymentTime: book.paymentTime,
                    paymentType: book.paymentType,
                    cancelationPermission: compareCurrentAndEndTime(NaiveDateTime.utc_now(), book.startDateTime) == :gt,
                    status: book.status,
                    place: Enum.map(book.place.area.coordinates,
                                     fn point -> {lng, lat} = point
                                        %{lng: lng, lat: lat}
                                     end),
                    cost:  Tartupark.PaymentAPIController.payment_calculate(book, book.place.zone),
                    payment: case book.payment do
                              nil -> nil
                              payment ->  %{payment_code: payment.payment_code,
                                            inserted_at: payment.inserted_at,
                                            cost: payment.cost,
                                            payment_id: payment.id}
                             end}
                end)
      |> Enum.filter(fn book -> book.status == "available" end)

      conn
      |> put_status(201)
      |> json(%{msg: "Bookings are available.", bookings: bookings})
  end

  def create(conn,  params) do

    user = Guardian.Plug.current_resource(conn)
    %{
       "id" => place_id,
       "startDateTime" => startDateTime,
       "endDateTime" => endDateTime,
       "paymentTime" => paymentTime,
       "paymentType" => paymentType
     } = params["parking_address"]


     start_time = parseToNaiveDateTime(startDateTime)
     case paymentType do
         "Hourly" -> end_time = parseToNaiveDateTime(endDateTime)
          _       -> end_time = nil
     end
     booking_params = %{startDateTime: start_time, endDateTime: end_time, paymentTime: paymentTime, paymentType: paymentType, status: "available"}
     booking_place_bind = Ecto.build_assoc(Repo.get(Place, place_id), :bookings, booking_params)
     booking = Ecto.build_assoc(user, :bookings, booking_place_bind)
               |> Repo.insert!

    payment =
    case Map.get(Map.get(params, "paymentParams"), "cost") do
       nil   ->  nil
       cost -> Tartupark.PaymentAPIController.create(conn, %{"bookingId" => booking.id, "cost" => cost})
    end

    case payment do
       nil          -> conn |> put_status(201) |> json(%{msg: "Booking has been done.", booking_id: booking.id})

       payment_conn ->
         case payment_conn.status do
            201 -> conn |> put_status(201) |> json(%{msg: "Booking with payment has been done.", booking_id: booking.id})
            _   ->  Repo.delete booking
                    conn |> put_status(402) |> json(%{msg: "Payment error has occured."})
         end
    end
  end

  def update(conn, %{"booking_id" => booking_id, "endDateTime" => end_time}) do
    booking = Repo.get!(Booking, booking_id)
    changeset = Ecto.Changeset.change(booking, endDateTime: parseToNaiveDateTime(end_time))
    case Repo.update changeset do
      {:ok, _struct}       -> conn
                             |> put_status(200)
                             |> json(%{msg: "Booking parameters successfully updated"})
      {:error, _changeset} -> conn
                             |> put_status(400)
                             |> json(%{msg: "Booking parameters were not updated"})
    end
  end

  def delete(conn, %{"booking_id" => booking_id}) do
    booking = Repo.get!(Booking, booking_id)
    if NaiveDateTime.compare(booking.startDateTime, NaiveDateTime.utc_now()) == :lt do
      changeset = Ecto.Changeset.change(booking, status: "canceled")
      case Repo.update changeset do
        {:ok, _struct}       -> conn
                                 |> put_status(200)
                                 |> json(%{msg: "Booking 'id: #{booking.id}' was deleted successfully."})
        {:error, _changeset} -> conn
                                 |> put_status(400)
                                 |> json(%{msg: "Booking 'id: #{booking.id}' could not be deleted."})
      end
    else
      conn
       |> put_status(423)
       |> json(%{msg: "Booking 'id: #{booking.id}' could not be deleted. Too late."})
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
    start_time = parseToNaiveDateTime(params["startDateTime"])
    end_time = parseToNaiveDateTime(params["endDateTime"])
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
                                                   if book.status == "available" do
                                                     case checkBetweenOrAfter(start_time, end_time, book.startDateTime, book.endDateTime) do
                                                       true -> capacity-1
                                                       false -> capacity
                                                     end
                                                   else
                                                     capacity
                                                   end
                                                 end),
                            startDateTime: start_time,
                            endDateTime: end_time,
                            parkingSearchRadius: params["parkingSearchRadius"],
                            paymentTime: params["paymentTime"],
                            paymentType: params["paymentType"],
                            cost: Tartupark.PaymentAPIController.payment_calculate(%{startDateTime: start_time, endDateTime: end_time, paymentType: params["paymentType"]},
                                                                                   %{costHourly: park_place.zone.costHourly, costRealTime: park_place.zone.costRealTime})
                          }
                          end))

    locations = Enum.filter(locations, fn loc -> loc.capacity > 0 end)
    # IO.inspect locations
    # IO.inspect locations
    conn
    |> put_status(200)
    |> json(locations)
  end

  def parseToNaiveDateTime(dateTime) when dateTime != nil do
    startDateTime = Regex.scan(~r/\d+/, dateTime, trim: true)
    |> List.flatten
    |> Enum.map(fn calendarElem -> Integer.parse(calendarElem) |> elem(0)  end)
    case length(startDateTime) do
       6 -> [year, month, day, hour, minute, second] = startDateTime
       7 -> [year, month, day, hour, minute, second, _millisecond] = startDateTime
       8 -> [year, month, day, hour, minute, second, _timezone1, _timezone2] = startDateTime
    end
    NaiveDateTime.new(year, month, day, hour, minute, second) |> elem(1)
  end
  def parseToNaiveDateTime(dateTime), do: nil

  def compareCurrentAndEndTime(current, end_time) do
     case end_time do
       nil -> false
       _   -> NaiveDateTime.compare(current, end_time) == :lt
     end
  end

  def checkBetweenOrAfter(start_1, end_1, start_2, end_2) do
    case {start_1, end_1, start_2, end_2} do
      {st1, nil, st2, nil} ->                                 true
      {st1, nil, _st2, ed2} when ed2 != nil ->                 NaiveDateTime.compare(NaiveDateTime.add(ed2, -120), st1) == :gt

      {_st1, ed1, st2, nil} when ed1 != nil ->                NaiveDateTime.compare(ed1, st2) == :gt or
                                                              NaiveDateTime.compare(ed1, st2) == :eq

      {st1, ed1, st2, ed2} when ed1 != nil and ed2 != nil -> not ((NaiveDateTime.compare(st1, st2) == :lt   and
                                                                   NaiveDateTime.compare(ed1, st2) == :lt)  or
                                                                   NaiveDateTime.compare(NaiveDateTime.add(ed2, -120), st1) == :lt)

       _ ->                                                   false
    end
  end
end
