defmodule Tartupark.Authentication do
  def check_credentials(conn, user, password) do
    if user && Comeonin.Pbkdf2.checkpw(password, Comeonin.Pbkdf2.hashpwsalt(password)) do
        {:ok, conn}
    else
        {:error, conn}
    end
  end
end