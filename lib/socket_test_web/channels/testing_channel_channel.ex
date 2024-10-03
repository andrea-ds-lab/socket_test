defmodule SocketTestWeb.TestingChannelChannel do
  use SocketTestWeb, :channel
  alias SocketTest.Chat
  # Import the Ollama interaction module
  alias SocketTestWeb.OllamaInteraction
  alias Ecto

  @impl true
  def join("testing_channel:" <> _channel_name, payload, socket) do
    if authorized?(payload) do
      {:ok, socket}
    else
      {:error, %{reason: "unauthorized"}}
    end
  end

  @impl true
  def handle_in("ping", payload, socket) do
    {:reply, {:ok, payload}, socket}
  end

  @impl true
  def handle_in("shout", payload, socket) do
    broadcast(socket, "shout", payload)
    {:noreply, socket}
  end

  @impl true
  def handle_in("btn_track", payload, socket) do
    IO.inspect(payload)
    {:noreply, socket}
  end

  @impl true
  def handle_in(
        "new_msg",
        %{
          "body" => body,
          "user" => user,
          "boosted" => boosted,
          "channel" => channel,
          "timestamp" => timestamp
        } = payload,
        socket
      ) do
    IO.inspect(payload)
    IO.puts("#{body}, #{user}, #{boosted}, #{channel}")

    # Convert timestamp to UTC datetime (if it's in milliseconds)
    timestamp = DateTime.from_unix!(timestamp, :millisecond)

    # Insert the message into the database
    case Chat.create_message(%{
           body: body,
           user: user,
           boosted: boosted,
           channel: channel,
           timestamp: timestamp
         }) do
      {:ok, _message} ->
        if boosted do
          # Call the Ollama API asynchronously
          Task.start(fn ->
            case OllamaInteraction.interact_with_ollama(body) do
              {:ok, response} ->
                # Save the response with username "llama3-chatqa"
                _ =
                  Chat.create_message(%{
                    body: response,
                    user: "IA",
                    boosted: true,
                    channel: channel,
                    # Set to current UTC time
                    timestamp: DateTime.utc_now()
                  })

                # Broadcast the response back to the socket
                broadcast(socket, "new_msg", %{
                  body: response,
                  user: "IA",
                  boosted: true,
                  channel: channel,
                  timestamp: DateTime.utc_now()
                })

              {:error, reason} ->
                # Handle Ollama API error (if needed)
                broadcast(socket, "error_msg", %{error: reason})
            end
          end)
        end

        # Broadcast the original message to others
        broadcast(socket, "new_msg", payload)
        {:noreply, socket}

      {:error, changeset} ->
        # Extract error messages from the changeset
        errors =
          changeset
          |> Ecto.Changeset.traverse_errors(&translate_error/1)
          |> Enum.map(fn {field, messages} -> %{field: field, messages: messages} end)

        # Reply with formatted error messages
        {:reply, {:error, %{errors: errors}}, socket}
    end
  end

  # Helper function to translate error messages
  defp translate_error({msg, opts}) do
    # Customize this function to translate error messages
    Ecto.Changeset.default_error_message(msg, opts)
  end

  def handle_in(_, _payload, socket) do
    # Handle other messages if needed
    {:noreply, socket}
  end

  # Add authorization logic here as required.
  defp authorized?(_payload) do
    true
  end

  @impl true
  def terminate(_reason, _socket) do
    IO.puts("A client has left the channel")
    :ok
  end
end
