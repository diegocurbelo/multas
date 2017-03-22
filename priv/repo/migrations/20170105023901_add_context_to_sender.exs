defmodule Multas.Repo.Migrations.AddContextToSender do
  use Ecto.Migration

  def change do
    alter table(:senders) do
      add :context, :string, default: "{}"
    end
  end
end
