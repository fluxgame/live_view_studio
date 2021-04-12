defmodule LiveViewStudio.Repo.Migrations.CreateFlight do
  use Ecto.Migration

  def change do
    create table(:flight) do
      add :number, :string
      add :origin, :string
      add :destination, :string
      add :departure_time, :utc_datetime
      add :arrival_time, :utc_datetime

      timestamps()
    end

  end
end
