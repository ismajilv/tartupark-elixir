defmodule Tartupark.Repo.Migrations.AddFreeTimeLimitToZones do
  use Ecto.Migration

  def change do
    alter table(:zones) do
      add :freeTimeLimit, :integer
      add :tag, :string
    end
  end
end
