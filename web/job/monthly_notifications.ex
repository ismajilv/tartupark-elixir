# defmodule Tartupark.MonthlyNofications do
#     use GenServer
#
#     # Receiving "request" and starting process
#     def start_link(request) do
#         GenServer.start_link(Tartupark.MonthlyNofications, request, name: :monthly_notifications)
#     end
#
#     # Initializing "request" when processes starts from "start_link"
#     def init(request) do
#         Process.send_after(self(), :notify_customer, @decision_timeout)
#         {:ok, request}
#     end
#
#     # calls handle_cast(:accept_booking, request)
#     def accept_booking(booking_reference) do
#         GenServer.cast(booking_reference, :accept_booking)
#     end
#
#     # Booking accepted
#     def handle_cast(:accept_booking, request) do
#         Takso.Endpoint.broadcast("customer:"<>request.customer_username, "requests", %{msg: "taxi arriving soon. After #{round(request.pickup_time/60)} mins"})
#         {:stop, :normal, request}
#     end
#
#     # Handling process
#     def handle_info(:notify_customer, request) do
#         # With the following line, the backend is broadcasting a message through the channel "customer:lobby"
#         # Henceforth, the following line must be updated for using private channels
#         # driver = List.first(request.drivers)
#         GenServer.cast(String.to_atom("booking_#{request.booking_id}"), :reject_booking)
#         {:noreply, request}
#     end
#
#     def millsecsToEndOfMonth do
#       time = Regex.scan(~r/\d+/, to_string(NaiveDateTime.utc_now())) |> List.flatten()
#       [year, month, _day, _hour, _minute, _second, _millisecond] = time
#       year = year |> Integer.parse |> elem(0)
#       month = month |> Integer.parse |> elem(0)
#       last_day = :calendar.last_day_of_the_month(year, month)
#     end
# end
