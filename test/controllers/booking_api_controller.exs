defmodule Tartupark.BookingAPIControllerTest do
    use Tartupark.ConnCase
    alias Tartupark.{BookingAPIController, User, UserAPIController}
 

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
                    "id" => 3,                                        
                    "parkingStartTime" => "2017-12-12T18:11:03", 
                    "parkingEndTime" => nil,  
                    "paymentTime" => "Before Parking", 
                    "paymentType" => "Real Time"                           
                }
               
        
        conn = post(conn, "api/bookings", params)
        assert conn.status == 201
    end
    
   # @tag :login
    # test "POST /api/register ", %{conn: conn} do
        
    #             params = %{"username" => "fred",
    #                        "email" => "fr@fr.com",                           
    #                        "license_number" => "123dsc"                           
    #                        }
                
    #             conn = post(conn, "/api/register", params)
    #             assert conn.status == 406
                
    #         end

end