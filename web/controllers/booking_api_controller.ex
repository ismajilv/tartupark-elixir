defmodule Tartupark.BookingAPIController do
  use Tartupark.Web, :controller
  import Ecto.Query, only: [from: 2]

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

  def search(conn, _params) do
    locations = [
      ['Tartu Ülikool', 58.3816146, 26.716936],
      ['Fortumo OÜ', 58.3791179, 26.7241151],
      ['Shooters Tartu', 58.3717589, 26.7024541]
    ]

    conn
    |> put_status(200)
    |> json(%{loc: locations})
  end
end
