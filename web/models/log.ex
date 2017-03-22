defmodule Multas.Log do
  use Multas.Web, :model

  schema "logs" do
    field :from, :string
    field :to, :string
    field :content, :string

    timestamps()
  end

  @doc """
  Builds a changeset based on the `struct` and `params`.
  """
  def changeset(struct, params \\ %{}) do
    struct
    |> cast(params, [:from, :to, :content])
    |> validate_required([:content])
  end
end
