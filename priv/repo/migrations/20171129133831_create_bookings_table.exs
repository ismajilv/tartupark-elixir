defmodule Tartupark.Repo.Migrations.CreateBookingsTable do
  use Ecto.Migration

  def change do
    create table(:bookings) do
      add :startDateTime, :naive_datetime
      add :endDateTime, :naive_datetime
      add :paymentTime, :string
      add :place_id, references(:places)
      add :user_id, references(:users)

      timestamps()
    end
  end
end
