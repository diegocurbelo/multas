defmodule Multas.Notification do
  use Multas.Web, :model

  schema "notifications" do
    field :facebook_id, :string
    field :plate, :string
    field :active, :boolean, default: false

    timestamps()
  end

  @doc """
  Builds a changeset based on the `struct` and `params`.
  """
  def changeset(struct, params \\ %{}) do
    struct
    |> cast(params, [:facebook_id, :plate, :active])
    |> validate_required([:facebook_id, :plate, :active])
  end
end
