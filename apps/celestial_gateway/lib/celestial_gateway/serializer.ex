defmodule CelestialGateway.Serializer do
  @moduledoc false
  @behaviour CelestialNetwork.Socket.Serializer

  alias CelestialGateway.Crypto
  alias CelestialNetwork.Socket.{Broadcast, Message}

  @impl true
  def fastlane!(%Broadcast{} = msg) do
    data = CelestialProtocol.encode([msg.event, msg.payload])
    {:socket_push, :plain, data |> IO.iodata_to_binary() |> Crypto.encrypt()}
  end

  @impl true
  def encode!(%Message{} = msg) do
    data = CelestialProtocol.encode([msg.event, msg.payload])
    {:socket_push, :plain, data |> IO.iodata_to_binary() |> Crypto.encrypt()}
  end

  @impl true
  def decode!(raw_message, _opts) do
    [ref, topic, event, payload | _] =
      raw_message
      |> Crypto.decrypt()
      |> CelestialProtocol.decode()

    %Message{topic: topic, event: event, payload: payload, ref: ref}
  end
end
