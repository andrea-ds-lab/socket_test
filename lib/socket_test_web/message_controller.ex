defmodule SocketTestWeb.MessageController do
  use SocketTestWeb, :controller
  alias SocketTest.Repo
  alias SocketTest.Chat.Message
  import Ecto.Query
  import Plug.Conn

  @max_initial_fetched_messages 25

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
        order_by: [desc: m.id],   # Order by descending ID to get the latest messages
        limit: @max_initial_fetched_messages                 # Limit to the last 25 messages

    messages = Repo.all(query)
    IO.puts("Length: #{length(messages)}")

    # Optionally reverse the list to keep the messages in ascending order
    messages = Enum.reverse(messages)

    json(conn, %{messages: messages})
  end

end
