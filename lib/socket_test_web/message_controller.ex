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

  def index(conn, %{"amount" => amount} = params) do
    amount = String.to_integer(amount)

    case Map.get(params, "id") do
      nil ->
        # No "id" provided, fetch the latest messages (either 100 or fewer)
        messages = Message.fetch_latest_messages(Repo, nil, amount)
        json(conn, %{messages: messages})

      id ->
        # If "id" is provided, ensure it's a valid integer
        case Integer.parse(id) do
          {parsed_id, ""} ->
            messages = Message.fetch_latest_messages(Repo, parsed_id, amount)
            json(conn, %{messages: messages})

          :error ->
            conn
            |> put_status(:bad_request)
            |> json(%{error: "Invalid id format"})
        end
    end
  end

  def index(conn, _params) do
    query =
      from m in Message,
        order_by: [asc: m.inserted_at]

    messages = Repo.all(query)
    json(conn, %{messages: messages})
  end
end
