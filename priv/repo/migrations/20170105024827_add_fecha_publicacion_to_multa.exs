defmodule Multas.Repo.Migrations.AddFechaPublicacionToMulta do
  use Ecto.Migration

  def change do
    alter table(:multas) do
      add :fecha_publicacion, :string
      add :impo_page_id, references(:impo_pages, on_delete: :delete_all)
    end

    create index(:multas, [:impo_page_id])
  end
end
