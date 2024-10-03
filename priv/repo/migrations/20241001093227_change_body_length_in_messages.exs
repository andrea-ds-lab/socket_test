defmodule SocketTest.Repo.Migrations.ChangeBodyLengthInMessages do
  use Ecto.Migration

  def change do
    alter table(:messages) do
      # Update to 1024 characters
      modify :body, :string, size: 1024
    end
  end
end
