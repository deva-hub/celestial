defmodule Nostalex.Entity do
  alias Nostalex.Socket.{Broadcast, Message}

  @doc """
  Broadcast an event to all subscribers of the socket topic.
  The event's message must be a serializable map.
  ## Examples
      iex> broadcast(socket, "new_message", %{id: 1, content: "hello"})
      :ok
  """
  def broadcast(socket, event, payload) do
    %{pubsub_server: pubsub_server, topic: topic} = socket
    message = %Broadcast{topic: topic, event: event, payload: payload}
    Phoenix.PubSub.broadcast(pubsub_server, topic, message)
  end

  @doc """
  Same as `broadcast/3`, but raises if broadcast fails.
  """
  def broadcast!(socket, event, payload) do
    %{pubsub_server: pubsub_server, topic: topic} = socket
    message = %Broadcast{topic: topic, event: event, payload: payload}
    Phoenix.PubSub.broadcast!(pubsub_server, topic, message)
  end

  @doc """
  Broadcast event from pid to all subscribers of the socket topic.
  The entity that owns the socket will not receive the published
  message. The event's message must be a serializable map.
  ## Examples
      iex> broadcast_from(socket, "new_message", %{id: 1, content: "hello"})
      :ok
  """
  def broadcast_from(socket, event, payload) do
    %{pubsub_server: pubsub_server, topic: topic, entity_pid: entity_pid} = socket
    message = %Broadcast{topic: topic, event: event, payload: payload}
    Phoenix.PubSub.broadcast_from(pubsub_server, entity_pid, topic, message)
  end

  @doc """
  Same as `broadcast_from/3`, but raises if broadcast fails.
  """
  def broadcast_from!(socket, event, payload) do
    %{pubsub_server: pubsub_server, topic: topic, entity_pid: entity_pid} = socket
    message = %Broadcast{topic: topic, event: event, payload: payload}
    Phoenix.PubSub.broadcast_from!(pubsub_server, entity_pid, topic, message)
  end

  def push(socket, event, payload) do
    message = %Message{event: event, payload: payload}
    send(socket.transport_pid, socket.serializer.encode!(message))
    :ok
  end
end
