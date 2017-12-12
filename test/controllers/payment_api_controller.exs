defmodule Tartupark.PaymentAPIControllerTest do
    use Tartupark.ConnCase
    alias Tartupark.{PaymentAPIController}
 



test "POST /api/payments", %{conn: conn} do
    
            params = %{"bookingId" => 20,
                       "cost" => nil                         
                       }
            
            conn = post(conn, "/api/payments", params)
            assert conn.status == 201
            
        end
end