defmodule Multas.Repo.Migrations.CreateSenderNotification do
  use Ecto.Migration

  def change do
    create table(:sender_notifications) do
      add :sender_id, :string
      add :matricula, :string
      add :enabled, :boolean, default: false, null: false
      add :times_asked, :integer
      add :last_multa_notified, references(:multas, on_delete: :delete_all)

      timestamps()
    end

    create index(:sender_notifications, [:sender_id, :matricula])
    create index(:sender_notifications, [:matricula])
  end
end
