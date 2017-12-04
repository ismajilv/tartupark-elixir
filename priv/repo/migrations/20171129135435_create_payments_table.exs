defmodule Tartupark.Repo.Migrations.CreatePaymentsTable do
  use Ecto.Migration

  def change do
    create table(:payments) do
      add :type, :string
      add :cost, :float
      add :status, :string
      add :booking_id, references(:bookings)

      timestamps()
    end
  end
end
