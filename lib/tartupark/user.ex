defmodule Tartupark.User do
  use Ecto.Schema
  import Ecto.Changeset
  alias Tartupark.User


  schema "users" do
    field :encrypted_password, :string
    field :name, :string
    field :username, :string
    field :password, :string, virtual: true

    timestamps()
  end

  @doc false
  def changeset(%User{} = user, attrs) do
    user
    |> cast(attrs, [:name, :username, :encrypted_password])
    |> validate_required([:name, :username, :encrypted_password])
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
