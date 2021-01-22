defmodule CelestialWorld.Entity do
  alias Nostalex.Socket.Message

  def push(socket, event, payload) do
    message = %Message{event: event, payload: payload}
    Process.send_after(socket.transport_pid, socket.serializer.encode!(message), 5000)
    :ok
  end
end
