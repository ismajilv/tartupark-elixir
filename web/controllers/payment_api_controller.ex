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
    payment_code = :crypto.strong_rand_bytes(length) |> Base.url_encode64 |> binary_part(0, length)
    case Repo.get_by(Payment, payment_code: payment_code) do
      nil -> payment_code
      _ -> random_string(length)
    end
  end

end
