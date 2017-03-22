defmodule Multas.Repo.Migrations.CreateSender do
  use Ecto.Migration

  def change do
    create table(:senders) do
      add :sender_id, :string

      timestamps()
    end

    create index(:senders, [:sender_id])
  end
end
