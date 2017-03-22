defmodule Multas.Repo.Migrations.CreateTrafficTicket do
  use Ecto.Migration

  def change do
    create table(:traffic_tickets) do
      add :plate, :string
      add :date, :string
      add :location, :string
      add :reason, :string
      add :cost, :string
      add :publication_id, references(:publications, on_delete: :delete_all)
      add :publication_date, :string

      timestamps()
    end

    create index(:traffic_tickets, [:plate, :publication_date, :date])
  end
end
