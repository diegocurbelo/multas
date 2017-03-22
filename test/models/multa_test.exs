defmodule Multas.MultaTest do
  use Multas.ModelCase

  alias Multas.Multa

  @valid_attrs %{articulo: "some content", fecha: %{day: 17, hour: 14, min: 0, month: 4, sec: 0, year: 2010}, interseccion: "some content", intervenido: "some content", matricula: "some content", valor_ur: 42}
  @invalid_attrs %{}

  test "changeset with valid attributes" do
    changeset = Multa.changeset(%Multa{}, @valid_attrs)
    assert changeset.valid?
  end

  test "changeset with invalid attributes" do
    changeset = Multa.changeset(%Multa{}, @invalid_attrs)
    refute changeset.valid?
  end
end
