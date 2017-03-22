defmodule Multas.ImpoPageTest do
  use Multas.ModelCase

  alias Multas.ImpoPage

  @valid_attrs %{fecha: "some content", url: "some content"}
  @invalid_attrs %{}

  test "changeset with valid attributes" do
    changeset = ImpoPage.changeset(%ImpoPage{}, @valid_attrs)
    assert changeset.valid?
  end

  test "changeset with invalid attributes" do
    changeset = ImpoPage.changeset(%ImpoPage{}, @invalid_attrs)
    refute changeset.valid?
  end
end
