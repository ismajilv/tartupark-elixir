defmodule Tartupark.UserAPIControllerTest do
    use Tartupark.ConnCase
    alias Tartupark.{UserAPIController}
 



test "POST /api/register ", %{conn: conn} do
    
            params = %{"email" => "fe@fe.com", "fullName" => "fe", "license_number" => "123zz", "password" => "[FILTERED]", "username" => "fred"}
            
            conn = post(conn, "/api/register", params)
            assert conn.status == 201
            
        end
end