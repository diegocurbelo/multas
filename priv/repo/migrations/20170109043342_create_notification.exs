defmodule Multas.Repo.Migrations.CreateNotification do
  use Ecto.Migration

  def change do
    rename table(:senders), :sender_id, to: :facebook_id

    drop_if_exists index(:senders, [:senders_sender_id_index])
    create unique_index(:senders, [:facebook_id])

    create table(:notifications) do
      add :facebook_id, references(:senders, type: :string, column: :facebook_id, on_delete: :delete_all)
      add :plate, :string
      add :active, :boolean, default: false, null: false

      timestamps()
    end

    create index(:notifications, [:facebook_id, :plate])
    create index(:notifications, [:plate, :active])
  end
end
