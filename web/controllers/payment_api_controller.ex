defmodule Tartupark.PaymentAPIController do
  use Tartupark.Web, :controller
  alias Tartupark.{Payment, Booking}

  def create(conn, %{"bookingId" => booking_id, "cost" => cost}) do

    payment_code = random_string(21)
    payment = Ecto.build_assoc(Repo.get(Booking, booking_id), :payment, %{cost: cost, payment_code: payment_code})
              |> Repo.insert!
    conn
    |> put_status(201)
    |> json(%{msg: "Payment has been done.", payment_id: payment.id})
  end

  def update(conn, _params) do
    conn
    |> put_status(200)
    |> json(%{msg: "Notification sent to the customer"})
  end

  def random_string(length) do
    alpha = ["A","B","C","D","E","F","G","H","I","J","K","L","M","N","O","P","Q","R","S","T","U","V","W","X","Y","Z","1","2","3","4","5","6","7","8","9","0"]
    payment_code = ""
    payment_code = for _x <- 1..21, do: payment_code <> Enum.random(alpha)
    case Repo.get_by(Payment, payment_code: payment_code) do
      nil -> payment_code
      _ -> random_string(length)
    end
  end

end
