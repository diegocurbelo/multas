defmodule Multas.SenderTest do
  use Multas.ModelCase

  alias Multas.Sender

  @valid_attrs %{sender_id: "some content"}
  @invalid_attrs %{}

  test "changeset with valid attributes" do
    changeset = Sender.changeset(%Sender{}, @valid_attrs)
    assert changeset.valid?
  end

  test "changeset with invalid attributes" do
    changeset = Sender.changeset(%Sender{}, @invalid_attrs)
    refute changeset.valid?
  end
end
