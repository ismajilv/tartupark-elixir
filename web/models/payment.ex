defmodule Tartupark.Payment do
  use Tartupark.Web, :model

  schema "payments" do
    field :cost, :float
    field :card_params, :map
    belongs_to :booking, Tartupark.Booking
    timestamps()
  end

  @doc """
  Builds a changeset based on the `struct` and `params`.
  """
  def changeset(struct, params \\ %{}) do
    struct
    |> cast(params, [:cost, :card_params])
    |> validate_required([:cost, :card_params])
  end

end
