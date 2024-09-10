defmodule SocketTestWeb.TestingChannelChannel do
  use SocketTestWeb, :channel

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

  # Channels can be used in a request/response fashion by sending replies to requests from the client
  @impl true
  def handle_in("btn_track", payload, socket) do
    IO.inspect(payload)
    {:noreply, socket}
  end

  # It is also common to receive messages from the client and broadcast to everyone in the current topic (testing_channel:_channel_name).
  @impl true
  def handle_in("new_msg", payload, socket) do
    broadcast(socket, "new_msg", payload)
    {:noreply, socket}
  end

  def handle_in(_, payload, socket) do
    # Handle other messages if needed
    {:noreply, socket}
  end

  # Add authorization logic here as required.
  defp authorized?(_payload) do
    true
  end
end
