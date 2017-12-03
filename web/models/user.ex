defmodule Tartupark.User do
  use Tartupark.Web, :model

  schema "users" do
    field :name, :string
    field :username, :string
    field :password, :string
    has_many :bookings, Tartupark.Booking
    field :role, :string
    timestamps()
  end

  @doc """
  Builds a changeset based on the `struct` and `params`.
  """
  def changeset(struct, params \\ %{}) do
    struct
    |> cast(params, [:name, :username, :password, :role])
    |> validate_required([:name, :username, :password, :role])
    |> encrypted_password
  end

  def encrypted_password(changeset) do
    if changeset.valid? do
      put_change(changeset, :password,
                Comeonin.Pbkdf2.hashpwsalt(changeset.changes[:password]))
    else
      changeset
    end
  end

end
