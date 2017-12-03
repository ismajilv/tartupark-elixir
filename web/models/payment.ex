defmodule Tartupark.Payment do
  use Tartupark.Web, :model

  schema "payments" do
    field :type, :string
    field :cost, :float
    field :status, :string, default: "dept"
    belongs_to :booking, Tartupark.Booking
    timestamps()
  end

  @doc """
  Builds a changeset based on the `struct` and `params`.
  """
  def changeset(struct, params \\ %{}) do
    struct
    |> cast(params, [:type, :cost, :status])
    |> validate_required([:type, :cost, :status])
  end

end
