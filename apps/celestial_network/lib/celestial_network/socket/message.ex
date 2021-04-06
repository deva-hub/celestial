defmodule CelestialNetwork.Socket.Message do
  @moduledoc """
  Defines a message dispatched over transport to channels and vice-versa.

  The message format requires the following keys:

      example "messages", "messages:123"
    * `:event`- The string event name, for example "phx_join"
    * `:payload` - The message payload
    * `:id` - The unique integer id

  """

  @type t :: %CelestialNetwork.Socket.Message{}
  defstruct event: nil, payload: nil, id: nil

  @doc """
  Converts a map with string keys into a message struct.

  Raises `CelestialNetwork.Socket.InvalidMessageError` if not valid.
  """
  def from_map!(map) when is_map(map) do
    try do
      %CelestialNetwork.Socket.Message{
        event: Map.fetch!(map, "event"),
        payload: Map.fetch!(map, "payload"),
        id: Map.fetch!(map, "id")
      }
    rescue
      err in [KeyError] ->
        raise CelestialNetwork.Socket.InvalidMessageError, "missing key #{inspect(err.key)}"
    end
  end
end

defmodule CelestialNetwork.Socket.Broadcast do
  @moduledoc """
  Defines a message sent from pubsub to channels and vice-versa.
  The message format requires the following keys:
    * `:topic` - The string topic or topic:subtopic pair namespace, for example "messages", "messages:123"
    * `:event`- The string event name, for example "phx_join"
    * `:payload` - The message payload
  """

  @type t :: %CelestialNetwork.Socket.Broadcast{}
  defstruct topic: nil, event: nil, payload: nil
end
