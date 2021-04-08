defmodule CelestialPortal.Serializer do
  @moduledoc false
  @behaviour CelestialNetwork.Socket.Serializer

  alias CelestialPortal.Crypto
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
  def decode!(raw_message, opts) do
    decrypted_message = decrypt_message(raw_message, opts)
    [ref, topic, event, payload | _] = CelestialProtocol.decode(decrypted_message)
    %Message{topic: topic, event: event, payload: payload, ref: ref}
  end

  defp decrypt_message(message, opts) do
    case Keyword.get(opts, :key) do
      nil -> Crypto.decrypt(message)
      key -> Crypto.decrypt(message, key)
    end
  end
end
