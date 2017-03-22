defmodule Multas.Repo.Migrations.CreateLog do
  use Ecto.Migration

  def change do
    create table(:logs) do
      add :from, :string
      add :to, :string
      add :content, :string

      timestamps()
    end

  end
end
