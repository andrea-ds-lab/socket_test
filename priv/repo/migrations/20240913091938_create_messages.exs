defmodule SocketTest.Repo.Migrations.CreateMessages do
  use Ecto.Migration

  def change do
    create table(:messages) do
      add :body, :string
      add :user, :string
      add :boosted, :boolean, default: false, null: false
      add :channel, :string

      timestamps(type: :utc_datetime)
    end
  end
end
