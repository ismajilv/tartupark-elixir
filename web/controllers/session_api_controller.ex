defmodule Tartupark.SessionAPIController do
    use Tartupark.Web, :controller
    alias Tartupark.{Repo, User, Authentication}

    def create(conn, %{"username" => username, "password" => password}) do
      IO.inspect username
      user = Repo.get_by(User, username: username)
      case Authentication.check_credentials(conn, user, password) do

   end

    def delete(conn, _params) do
      {:ok, claims} = Guardian.Plug.claims(conn)
      conn
      |> Guardian.Plug.current_token
      |> Guardian.revoke!(claims)

      conn
      |> put_status(200)
      |> json(%{msg: "Good bye"})
    end

    def unauthenticated(conn, _params) do
      conn
      |> put_status(403)
      |> json(%{msg: "Welcome"})
    end
end
