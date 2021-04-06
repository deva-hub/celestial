defmodule CelestialNetwork.Socket.Serializer do
  @moduledoc """
  A behaviour that serializes incoming and outgoing socket messages.

  By default CelestialNetwork provides `CelestialNetwork.Socket.V2.JSONSerializer` that
  encodes to JSON and decodes JSON messages.

  Custom serializers may be configured in the socket.
  """

  @doc """
  Encodes a `CelestialNetwork.Socket.Broadcast` struct to fastlane format.
  """
  @callback fastlane!(CelestialNetwork.Socket.Broadcast.t()) ::
              {:socket_push, :plain, iodata()}
              | {:socket_push, :binary, iodata()}

  @doc """
  Encodes `CelestialNetwork.Socket.Message` and `CelestialNetwork.Socket.Reply` structs to push format.
  """
  @callback encode!(CelestialNetwork.Socket.Message.t() | CelestialNetwork.Socket.Reply.t()) ::
              {:socket_push, :plain, iodata()}
              | {:socket_push, :binary, iodata()}

  @doc """
  Decodes iodata into `CelestialNetwork.Socket.Message` struct.
  """
  @callback decode!(iodata, options :: Keyword.t()) :: CelestialNetwork.Socket.Message.t()
end
