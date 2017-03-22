defmodule Multas.Sender do
  use Multas.Web, :model

  schema "senders" do
    field :facebook_id, :string
    field :context, :string, default: "{}"

    timestamps()
  end

  @doc """
  Builds a changeset based on the `struct` and `params`.
  """
  def changeset(struct, params \\ %{}) do
    struct
    |> cast(params, [:facebook_id, :context])
    |> validate_required([:facebook_id])
  end
end
