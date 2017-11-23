defmodule Tartupark.Repo.Migrations.CreateLocations do
  use Ecto.Migration

  def change do
    create table(:locations) do
      add :lat, :float
      add :long, :float
      add :status, :string
      add :type, :string

      timestamps()
    end

  end
end
