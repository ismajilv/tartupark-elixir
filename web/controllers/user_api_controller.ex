defmodule Tartupark.UserAPIController do
  use Tartupark.Web, :controller
  import Ecto.Query, only: [from: 2]
  alias Tartupark.{Repo, User, Authentication}

  def create(conn, params) do
    %{"username" => username,  "email" => email} = params
    query = from user in User,
            where: user.username == ^username or user.email == ^email,
            select: user
    identical_users = Repo.all(query)
    if length(identical_users) == 0 do
      struct = Map.new(Enum.map(params, fn({key, value}) -> {String.to_atom(key), value} end))
      changeset = User.changeset(%User{}, struct)
      case Repo.insert(changeset) do
          {:ok, _user} ->
              conn
              |> put_status(201)
              |> json(%{msg: "Registered successfully."})
          {:error, _changeset} ->
              conn
              |> put_status(406)
              |> json(%{msg: "Wrong credentials format."})
      end
    else
      conn
      |> put_status(406)
      |> json(%{msg: "User with these credentials exists."})
    end

  end

end
