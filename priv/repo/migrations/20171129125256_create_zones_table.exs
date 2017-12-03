defmodule Tartupark.Repo.Migrations.CreateZonesTable do
  use Ecto.Migration

  def change do
    create table(:zones) do
      add :name, :string
      add :costHourly, :float
      add :costRealTime, :float
      add :busFree, :boolean, default: false
      add :motoFree, :boolean, default: false

      timestamps()
    end
  end
end
