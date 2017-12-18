defmodule Tartupark.MonthlyNofications do
    use GenServer
    alias Tartupark.{Booking, Payment}

    # Receiving "request" and starting process
    def start_link(request) do
        GenServer.start_link(Tartupark.MonthlyNofications, request, name: :monthly_notifications)
    end

    # Initializing "request" when processes starts from "start_link"
    def init(request) do
        Process.send_after(self(), :notify_customers, millsecsToEndOfMonth)
        {:ok, request}
    end

    # Handling process
    def handle_info(:notify_customers, request) do
        month = DateTime.utc_now().month
        year = DateTime.utc_now().year
        bookings =
          Repo.all(Booking)
          |> Repo.preload([:payment, :user, place: [:zone]])
          |> Enum.filter(fn booking ->
                            booking.payment == nil and
                            booking.endDateTime != nil and
                            booking.endDateTime.year ==  year and
                            booking.endDateTime.month <=  month and
                            Tartupark.PaymentAPIController.payment_calculate(booking, booking.place.zone) > 0
                          end)
        if length(bookings) > 0 do
          already_notified = %{}
          for booking in bookings do
             if Map.get(already_notified, String.to_atom(booking.user.id)) == nil do
               Takso.Endpoint.broadcast("customer:"<>booking.user.username, "requests", %{msg: "Monthly payment notification. You have booking(s) that should be payed. Go to 'Bookings Summary' to pay."})
               already_notified = Map.put_new(already_notified, String.to_atom(booking.user.id), booking.user.username)
             end
          end
        end
        Process.send_after(self(), :notify_customers, millsecsToEndOfMonth)
        {:ok, request}
    end




    def millsecsToEndOfMonth do
      time = DateTime.utc_now()
      time = %DateTime{year: time.year, month: time.month, day: time.day, zone_abbr: "EET",
                        hour: 13, minute: 0, second: 0, microsecond: {0, 0},
                        utc_offset: 7200, std_offset: 0, time_zone: "Eastern European Time"}
      year = time.year
      month = time.month

      case month do
        12 -> next_month = 1
              next_year = year+1
        _  -> next_month = month+1
              next_year = year
      end
      curr_last_day_of_month = :calendar.last_day_of_the_month(year, month)
      next_last_day_of_month = :calendar.last_day_of_the_month(next_year, next_month)
      current_last_date_of_month =  %DateTime{year: year, month: month, day: curr_last_day_of_month, zone_abbr: "EET",
                                      hour: 13, minute: 0, second: 0, microsecond: {0, 0},
                                      utc_offset: 7200, std_offset: 0, time_zone: "Eastern European Time"}
      next_last_date_of_month =  %DateTime{year: next_year, month: next_month, day: next_last_day_of_month, zone_abbr: "EET",
                                      hour: 13, minute: 0, second: 0, microsecond: {0, 0},
                                      utc_offset: 7200, std_offset: 0, time_zone: "Eastern European Time"}

      remaining_days = curr_last_day_of_month - time.day
      case remaining_days > 0 do
        true -> DateTime.diff(current_last_date_of_month, time, :millisecond)
        _    -> DateTime.diff(next_last_day_of_month, current_last_date_of_month, :millisecond)
      end
    end
end
