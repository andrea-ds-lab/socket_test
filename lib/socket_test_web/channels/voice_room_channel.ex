defmodule SocketTestWeb.VoiceRoomChannel do
  use Phoenix.Channel

  def join("voice_room:" <> room_id, _message, socket) do
    # Store the room ID in the socket assigns for reference
    socket = assign(socket, :room_id, room_id)

    # Notify other clients in the room about a new user joining
    # Send a message to self to handle after join
    send(self(), :after_join)
    {:ok, socket}
  end

  def handle_info(:after_join, socket) do
    # After successfully joining, you can push/broadcast messages
    broadcast(socket, "user_joined", %{user_id: socket.id})
    # Example push message
    push(socket, "welcome", %{message: "Welcome to the voice room!"})
    {:noreply, socket}
  end

  def handle_in("webrtc_offer", %{"offer" => offer}, socket) do
    # Broadcast the offer to other clients in the same room
    broadcast(socket, "webrtc_offer", %{offer: offer, from: socket.id})
    {:noreply, socket}
  end

  def handle_in("webrtc_answer", %{"answer" => answer}, socket) do
    # Broadcast the answer to the other client
    broadcast(socket, "webrtc_answer", %{answer: answer, from: socket.id})
    {:noreply, socket}
  end

  def handle_in("ice_candidate", %{"candidate" => candidate}, socket) do
    # Broadcast the ICE candidate to the other clients in the room
    broadcast(socket, "ice_candidate", %{candidate: candidate, from: socket.id})
    {:noreply, socket}
  end

  def terminate(_reason, socket) do
    # Optionally notify other clients about user leaving
    broadcast(socket, "user_left", %{user_id: socket.id})
  end
end
