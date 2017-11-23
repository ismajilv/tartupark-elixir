defmodule Takso.SessionAPIController do
    use Takso.Web, :controller
    alias Takso.{Repo,User,Authentication}

    def create(conn, %{"username" => username, "password" => password}) do
      user = Repo.get_by(User, username: username)
      case Authentication.check_credentials(conn, user, password) do
      {:ok, conn} ->
          {:ok, jwt, _full_claims} = Guardian.encode_and_sign(user, :token)
          conn
          |> put_status(201)
          |> json(%{token: jwt, role: user.role})
      {:error, conn} ->
          conn
          |> put_status(400)
          |> json(%{message: "Bad credentials"})
      end
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
      |> json(%{msg: "You are not logged in"})
    end
  end