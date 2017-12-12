defmodule Tartupark.UserAPIControllerTest do
    use Tartupark.ConnCase
    alias Tartupark.{UserAPIController}
 



test "POST /api/register ", %{conn: conn} do
    
            params = %{"username" => "fred",
                       "email" => "fr@fr.com",                           
                       "license_number" => "123dsc"                           
                       }
            
            conn = post(conn, "/api/register", params)
            assert conn.status == 406
            
        end
end