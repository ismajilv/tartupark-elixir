defmodule Tartupark.BookingAPIControllerTest do
    use Tartupark.ConnCase
    alias Tartupark.{BookingAPIController, User}
    
    setup %{conn: conn} = config do
        cond do
            config[:login] -> 
                user = Repo.insert!(%User{
                    fullName: "fred", username: "fred", password: "parool", email: "fr@fr.com", license_number: "123dsc" 
                    })
                IO.inspect user
                new_conn = Guardian.Plug.api_sign_in(conn, user)
                {:ok, conn: new_conn}
            true -> :ok
        end
    end
    
    @tag :login
    test "GET /", %{conn: conn} do

        params = %{"lngLat" => %{"lat" => 54.33, "lng" => 26.222}}
        
        conn = get(conn, "/", params)
        assert conn.status == 200
        
    end
 

    @tag :login
    test "POST /api/bookings ", %{conn: conn} do
        IO.inspect conn
        params = %{
            "parking_address" => [
                %{
                    "area" => [%{"lat" => 58.384039, "lng" => 26.718892}, %{"lat" => 58.384194, "lng" => 26.719535}, %{"lat" => 58.383635, "lng" => 26.720025}, %{"lat" => 58.3835, "lng" => 26.719102}], 
                    "capacity" => 100, 
                    "distance" => 293.71357411, 
                    "id" => 1, 
                    "parkingEndTime" => nil, 
                    "parkingSearchRadius" => "500 meters", 
                    "parkingStartTime" => "2017-12-07T12:10:17.693Z", 
                    "paymentTime" => "End of Month", 
                    "paymentType" => "Real Time", 
                    "shape" => "polygon", 
                    "zone" => %{"costHourly" => 1, "costRealTime" => 0.08, "description" => "Zone B", "freeTimeLimit" => 90, "tag" => "ZB", "zone_id" => 2}
                }
            ]
        }
        conn = post(conn, "/api/bookings", params)
        assert conn.status == 201
    end
        

end