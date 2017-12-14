defmodule Tartupark.PaymentAPIControllerTest do
    use Tartupark.ConnCase
    alias Tartupark.{PaymentAPIController, User}
 
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
test "POST /api/payments", %{conn: conn} do
    
            params = %{"bookingId" => 53,
                       "cost" => 20.0                       
                       }
            
            conn = post(conn, "api/payments", params)
            assert conn.status == 201
            
        end
end