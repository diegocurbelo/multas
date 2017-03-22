defmodule Multas.PublicationTest do
  use Multas.ModelCase

  alias Multas.Publication

  @valid_attrs %{date: "some content", name: "some content", processed: true, url: "some content"}
  @invalid_attrs %{}

  test "changeset with valid attributes" do
    changeset = Publication.changeset(%Publication{}, @valid_attrs)
    assert changeset.valid?
  end

  test "changeset with invalid attributes" do
    changeset = Publication.changeset(%Publication{}, @invalid_attrs)
    refute changeset.valid?
  end
end
