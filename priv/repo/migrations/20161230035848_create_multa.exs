defmodule Multas.Repo.Migrations.CreateMulta do
  use Ecto.Migration

  def change do
    create table(:multas) do
      add :matricula, :string
      add :fecha, :string
      add :interseccion, :string
      add :intervenido, :string
      add :articulo, :string
      add :valor_ur, :integer

      timestamps()
    end

    create index(:multas, [:matricula])
    create index(:multas, [:fecha])
  end
end
