defmodule Tartupark.Repo.Migrations.CreateZonesTable do
  use Ecto.Migration

  def change do
    create table(:zones) do
      add :name, :string
      add :costHourly, :float
      add :costRealTime, :float
      add :busFree, :boolean
      add :motoFree, :boolean
      add :freeTimeLimit, :integer
      add :tag, :string

      timestamps()
    end
  end
end
