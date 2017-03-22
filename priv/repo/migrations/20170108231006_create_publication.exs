defmodule Multas.Repo.Migrations.CreatePublication do
  use Ecto.Migration

  def change do
    create table(:publications) do
      add :name, :string
      add :date, :string
      add :url, :string
      add :processed, :boolean, default: false, null: false

      timestamps()
    end

  end
end
