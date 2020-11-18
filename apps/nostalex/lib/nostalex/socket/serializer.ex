defmodule Nostalex.Socket.Serializer do
  @moduledoc """
  A behaviour that serializes incoming and outgoing socket messages.

  By default Nostalex provides `Nostalex.Socket.V2.JSONSerializer` that
  encodes to JSON and decodes JSON messages.

  Custom serializers may be configured in the socket.
  """

  @doc """
  Encodes a `Nostalex.Socket.Broadcast` struct to fastlane format.
  """
  @callback fastlane!(Nostalex.Socket.Broadcast.t()) ::
              {:socket_push, :plain, iodata()}
              | {:socket_push, :binary, iodata()}

  @doc """
  Encodes `Nostalex.Socket.Message` and `Nostalex.Socket.Reply` structs to push format.
  """
  @callback encode!(Nostalex.Socket.Message.t() | Nostalex.Socket.Reply.t()) ::
              {:socket_push, :plain, iodata()}
              | {:socket_push, :binary, iodata()}

  @doc """
  Decodes iodata into `Nostalex.Socket.Message` struct.
  """
  @callback decode!(iodata, options :: Keyword.t()) :: Nostalex.Socket.Message.t()
end
