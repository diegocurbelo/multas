defmodule Multas.NotificationTest do
  use Multas.ModelCase

  alias Multas.Notification

  @valid_attrs %{active: true, plate: "some content", sender_id: "some content"}
  @invalid_attrs %{}

  test "changeset with valid attributes" do
    changeset = Notification.changeset(%Notification{}, @valid_attrs)
    assert changeset.valid?
  end

  test "changeset with invalid attributes" do
    changeset = Notification.changeset(%Notification{}, @invalid_attrs)
    refute changeset.valid?
  end
end
