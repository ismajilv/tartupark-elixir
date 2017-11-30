defmodule Tartupark.Repo.Migrations.ChangeLatAndLongTo_GEOPoint do
  use Ecto.Migration

  def change do
    alter table(:places) do
      remove :latitude
      remove :longitude
      add :point, :geometry 
    end
  end
end
