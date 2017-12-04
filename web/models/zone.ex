defmodule Tartupark.Zone do
  use Tartupark.Web, :model

  schema "zones" do
    field :description, :string
    field :costHourly, :float
    field :costRealTime, :float
    field :freeTimeLimit, :integer
    field :tag, :string
    has_many :places, Tartupark.Place

    timestamps()
  end

  @doc """
  Builds a changeset based on the `struct` and `params`.
  """
  def changeset(struct, params \\ %{}) do
    struct
    |> cast(params, [:description, :costHourly, :costRealTime, :freeTimeLimit, :tag])
    |> validate_required([:description, :costHourly, :costRealTime, :freeTimeLimit, :tag])
  end

end
