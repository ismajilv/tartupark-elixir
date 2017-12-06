defmodule Tartupark.Booking do
  use Tartupark.Web, :model

  schema "bookings" do
    field :startDateTime, :naive_datetime
    field :endDateTime, :naive_datetime
    field :paymentTime, :string
    belongs_to :place, Tartupark.Place
    belongs_to :user, Tartupark.User
    has_one :payment, Tartupark.Payment
    timestamps()
  end

  @doc """
  Builds a changeset based on the `struct` and `params`.
  """
  def changeset(struct, params \\ %{}) do
    struct
    |> cast(params, [:startTime, :endTime])
    |> validate_required([:startTime])
  end

end
