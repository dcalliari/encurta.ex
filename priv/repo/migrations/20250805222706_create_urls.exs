defmodule Encurta.Repo.Migrations.CreateUrls do
  use Ecto.Migration

  def change do
    create table(:urls) do
      add :url, :string
      add :short, :string

      timestamps(type: :utc_datetime)
    end

    create unique_index(:urls, [:short])
  end
end
