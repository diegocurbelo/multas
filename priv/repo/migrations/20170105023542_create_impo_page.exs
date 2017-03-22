defmodule Multas.Repo.Migrations.CreateImpoPage do
  use Ecto.Migration

  def change do
    create table(:impo_pages) do
      add :fecha, :string
      add :url, :string

      timestamps()
    end

    create index(:impo_pages, [:fecha])
  end
end
