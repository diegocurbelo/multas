defmodule Multas.Repo.Migrations.DropSenderNotification do
  use Ecto.Migration

  def change do
    drop table(:sender_notifications)
  end
end
