defmodule Tartupark.Payment do
  use Tartupark.Web, :model

  schema "payments" do
    field :cost, :float
    field :payment_code, :string
    belongs_to :booking, Tartupark.Booking
    timestamps()
  end

  @doc """
  Builds a changeset based on the `struct` and `params`.
  """
  def changeset(struct, params \\ %{}) do
    struct
    |> cast(params, [:cost, :payment_code])
    |> validate_required([:cost, :payment_code])
  end

end
