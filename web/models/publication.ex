defmodule Multas.Publication do
  use Multas.Web, :model

  schema "publications" do
    field :name, :string
    field :date, :string
    field :url, :string
    field :processed, :boolean, default: false

    timestamps()
  end

  @doc """
  Builds a changeset based on the `struct` and `params`.
  """
  def changeset(struct, params \\ %{}) do
    struct
    |> cast(params, [:name, :date, :url, :processed])
    |> validate_required([:date, :url])
  end
end
