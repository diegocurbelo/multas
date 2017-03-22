defmodule Multas.SenderNotificationTest do
  use Multas.ModelCase

  alias Multas.SenderNotification

  @valid_attrs %{enabled: true, matricula: "some content", sender_id: "some content", times_asked: 42}
  @invalid_attrs %{}

  test "changeset with valid attributes" do
    changeset = SenderNotification.changeset(%SenderNotification{}, @valid_attrs)
    assert changeset.valid?
  end

  test "changeset with invalid attributes" do
    changeset = SenderNotification.changeset(%SenderNotification{}, @invalid_attrs)
    refute changeset.valid?
  end
end
