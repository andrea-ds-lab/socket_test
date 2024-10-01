defmodule SocketTest.Repo.Migrations.ChangeBodyLengthInMessages do
  use Ecto.Migration

  def change do
    alter table(:messages) do
      modify :body, :string, size: 1024 # Update to 1024 characters
    end
  end

end
