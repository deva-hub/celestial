defmodule CelestialPortal.Serializer do
  @moduledoc false
  @behaviour Nostalex.Socket.Serializer

  alias CelestialPortal.Crypto
  alias Nostalex.Socket.{Broadcast, Message}

  @impl true
  def fastlane!(%Broadcast{} = msg) do
    data = Noslib.encode([msg.event, msg.payload])
    {:socket_push, :plain, data |> IO.iodata_to_binary() |> Crypto.encrypt()}
  end

  @impl true
  def encode!(%Message{} = msg) do
    data = Noslib.encode([msg.event, msg.payload])
    {:socket_push, :plain, data |> IO.iodata_to_binary() |> Crypto.encrypt()}
  end

  @impl true
  def decode!(raw_message, opts) do
    decrypted_message = decrypt_message(raw_message, opts)
    [id, event, payload | _] = Noslib.decode(decrypted_message)
    %Message{event: event, payload: payload, id: id}
  end

  defp decrypt_message(message, opts) do
    case Keyword.get(opts, :key) do
      nil -> Crypto.decrypt(message)
      key -> Crypto.decrypt(message, key)
    end
  end
end
