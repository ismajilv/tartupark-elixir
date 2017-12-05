defmodule Tartupark.BookingAPIControllerTest do
    use Tartupark.ConnCase
    alias Tartupark.BookingAPIController
    
    test "GET /", %{conn: conn} do

        
        params = %{"lngLat" => %{"lat" => 54.33, "lng" => 26.222}}
        result  = BookingAPIControllerTest.search(conn, params)
        assert result = 

        conn = get conn, "/"
        assert html_response(conn, 200) =~ "Welcome to Phoenix!"
    end
end