defmodule SocketTestWeb.MessageController do
  use SocketTestWeb, :controller
  alias SocketTest.Repo
  alias SocketTest.Chat.Message
  import Ecto.Query
  import Plug.Conn

  def index(conn, %{"start_from" => start_from}) do
    case DateTime.from_iso8601(start_from) do
      {:ok, start_time, 0} ->
        messages =
          Message
          |> where([m], m.inserted_at >= ^start_time)
          |> Repo.all()

    json(conn, %{messages: messages})

      {:error, _} ->
        conn
        |> put_status(:bad_request)
        |> json(%{error: "Invalid start_from format"})
    end
  end

  def index(conn, _params) do
    query =
      from m in Message,
        # Change to `desc` if you want descending order
        order_by: [asc: m.inserted_at]

    messages = Repo.all(query)
    json(conn, %{messages: messages})
  end
end
