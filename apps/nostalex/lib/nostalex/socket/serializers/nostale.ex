defmodule Nostalex.Socket.NostaleSerializer do
  @moduledoc false
  @behaviour Nostalex.Socket.Serializer

  alias Nostalex.Socket.{Broadcast, Message}

  @impl true
  def fastlane!(%Broadcast{} = msg) do
    data = Noslib.encode([msg.event, msg.payload])
    {:socket_push, :plain, data}
  end

  @impl true
  def encode!(%Message{} = msg) do
    data = Noslib.encode([msg.event, msg.payload])
    {:socket_push, :plain, data}
  end

  @impl true
  def decode!(raw_message, _opts) do
    [id, event, payload | _] = Noslib.decode(raw_message)

    %Message{
      event: event,
      payload: payload,
      id: id
    }
  end
end
