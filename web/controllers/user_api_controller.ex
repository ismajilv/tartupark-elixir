defmodule Tartupark.UserAPIController do
  use Tartupark.Web, :controller
  alias Tartupark.{Repo, User}

  def create(conn, params) do
    %{"username" => username,  "email" => email, "license_number" => license_number} = params
    query = from user in User,
            where: user.username == ^username or user.email == ^email or user.license_number == ^license_number,
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
