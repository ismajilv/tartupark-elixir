defmodule Tartupark.Repo.Migrations.CreatePlacesTable do
  use Ecto.Migration

  def up do
    execute "CREATE EXTENSION IF NOT EXISTS postgis"
    create table(:places) do
      add :capacity, :integer
      add :status, :string
      add :zone_id, references(:zones)
      add :shape, :string
      timestamps()
    end
    execute("SELECT AddGeometryColumn ('places', 'area', 4326, 'MULTIPOINT', 2);")
    # TODO add index using gist
  end
end
