defmodule SocketTestWeb.CallChannel do
  use SocketTestWeb, :channel

  # Join channel for the specific user and assign the caller
  def join("call:" <> username, _params, socket) do
    # Assign the caller's username to the socket
    socket = assign(socket, :caller, username)
    {:ok, socket}
  end

  # Handle incoming call offer
  def handle_in("call_user", %{"to" => callee, "offer" => offer, "caller" => caller}, socket) do
    # Broadcast the offer to the callee and include the caller information
    SocketTestWeb.Endpoint.broadcast!("call:#{callee}", "incoming_call", %{
      offer: offer,
      caller: caller
    })

    {:noreply, socket}
  end

  # Handle answering a call
  def handle_in("answer_call", %{"answer" => answer, "caller" => caller}, socket) do
    # Notify the caller with the answer
    SocketTestWeb.Endpoint.broadcast!("call:#{caller}", "call_answered", %{answer: answer})
    {:noreply, socket}
  end

  # Handle ICE candidate
  def handle_in("ice_candidate", %{"candidate" => candidate, "caller" => caller}, socket) do
    # Forward ICE candidate to the correct peer
    SocketTestWeb.Endpoint.broadcast!("call:#{caller}", "ice_candidate", %{candidate: candidate})
    {:noreply, socket}
  end
end
