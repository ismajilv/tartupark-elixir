defmodule Tartupark.User do
  use Tartupark.Web, :model

  schema "users" do
    field :fullName, :string
    field :username, :string
    field :password, :string, virtual: true
    field :encrypted_password, :string
    field :email, :string
    timestamps()
  end

  @doc """
  Builds a changeset based on the `struct` and `params`.
  """
  def changeset(struct, params \\ %{}) do
    struct
    |> cast(params, [:fullName, :username, :password, :email])
    |> validate_required([:fullName, :username, :password, :email])
    |> validate_format(:email, ~r/@/)
    |> encrypt_password
  end

  def encrypt_password(changeset) do
    if changeset.valid? do
      put_change(changeset, :encrypted_password, Comeonin.Pbkdf2.hashpwsalt(changeset.changes[:password]))
    else
      changeset
    end
  end

end
