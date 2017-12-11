defmodule Tartupark.PaymentAPIController do
  use Tartupark.Web, :controller
  alias Tartupark.{Payment, Booking}

  def create(conn, params) do
    %{"cardParams" => card_params,
      "bookingId" => booking_id,
      "cost" => cost} = params

      payment = Ecto.build_assoc(Repo.get(Booking, booking_id), :payment, %{card_params: card_params, cost: cost})
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
end
