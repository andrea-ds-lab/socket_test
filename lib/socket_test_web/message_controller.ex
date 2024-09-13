defmodule SocketTestWeb.MessageController do
  use SocketTestWeb, :controller
  alias SocketTest.Repo
  alias SocketTest.Chat.Message
  import Ecto.Query, only: [from: 1, from: 2]
  import Plug.Conn

  def index(conn, _params) do
    query = from m in Message,
      order_by: [asc: m.inserted_at]  # Change to `desc` if you want descending order

    messages = Repo.all(query)
    json(conn, %{messages: messages})
  end
end
