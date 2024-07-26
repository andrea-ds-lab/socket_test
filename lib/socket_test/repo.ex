defmodule SocketTest.Repo do
  use Ecto.Repo,
    otp_app: :socket_test,
    adapter: Ecto.Adapters.Postgres
end
