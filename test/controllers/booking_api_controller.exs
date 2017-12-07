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
        
        params = %{                    
                    "id" => 40, 
                    "parkingEndTime" => nil,                     
                    "parkingStartTime" => "2017-12-07T13:57:43.090Z", 
                    "paymentTime" => "End of Month", 
                    "paymentType" => "Real Time"                            
                }
               
        
        conn = post(conn, "/api/bookings", params)
        assert conn.status == 201
    end
        

end