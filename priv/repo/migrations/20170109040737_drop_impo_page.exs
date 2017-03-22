defmodule Multas.Repo.Migrations.DropImpoPage do
  use Ecto.Migration

  def change do
    drop table(:impo_pages)
  end
end
