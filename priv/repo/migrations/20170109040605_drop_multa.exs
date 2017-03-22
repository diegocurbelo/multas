defmodule Multas.Repo.Migrations.DropMulta do
  use Ecto.Migration

  def change do
    drop table(:multas)
  end
end
