defmodule Tartupark.Repo.Migrations.CreatePlacesTable do
  use Ecto.Migration

  def change do
    create table(:places) do
      add :latitude, :float
      add :longitude, :float
      add :capacity, :integer
      add :status, :string, default: "available"
      add :zone_id, references(:zones)

      timestamps()
    end
  end
end
