defmodule Tartupark.Booking do
  use Tartupark.Web, :model

  schema "bookings" do
    field :startDateTime, :naive_datetime
    field :endDateTime, :naive_datetime
    field :paymentTime, :string
    field :paymentType, :string
    field :status, :string, default: "available"
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
    |> cast(params, [:startDateTime, :endDateTime, :paymentTime, :paymentType, :status])
    |> validate_required([:startDateTime, :endDateTime, :paymentTime, :paymentType, :status])
  end

end
