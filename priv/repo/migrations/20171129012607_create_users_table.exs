defmodule Tartupark.Repo.Migrations.CreateUsersTable do
  use Ecto.Migration

  def change do
    create table(:users) do
      add :username, :string
      add :encrypted_password, :string
      add :email, :string

      timestamps()
    end
  end
end
