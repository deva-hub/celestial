defmodule CelestialWorld.Entity do
  alias Nostalex.Socket.Message

  def push(socket, event, payload) do
    message = %Message{event: event, payload: payload}
    send(socket.transport_pid, socket.serializer.encode!(message))
    :ok
  end
end
