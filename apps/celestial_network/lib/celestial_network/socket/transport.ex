defmodule CelestialNetwork.Socket.Transport do
  @moduledoc false

  @type state :: term()

  @doc """
  Initializes the socket state.

  This must be executed from the process that will effectively
  operate the socket.
  """
  @callback init(state) :: {:ok, state}

  @doc """
  Connects to the socket.

  The transport passes a map of metadata and the socket
  returns `{:ok, state}` or `:error`. The state must be
  stored by the transport and returned in all future
  operations.

  This function is used for authorization purposes and it
  may be invoked outside of the process that effectively
  runs the socket.

  In the default `Phoenix.Socket` implementation, the
  metadata expects the following keys:

    * `:endpoint` - the application endpoint
    * `:transport` - the transport name
    * `:params` - the connection parameters
    * `:options` - a keyword list of transport options, often
      given by developers when configuring the transport.
      It must include a `:serializer` field with the list of
      serializers and their requirements

  """
  @callback connect(transport_info :: map) :: {:ok, state} | :error

  @doc """
  Handles incoming socket messages.

  The message is represented as `{payload, options}`. It must
  return one of:

    * `{:ok, state}` - continues the socket with no reply
    * `{:stop, reason, state}` - stops the socket

  The `reply` is a tuple contain an `opcode` atom and a message that can
  be any term. The built-in websocket transport supports both `:plain` and
  `:binary` opcode and the message must be always iodata. Long polling only
  supports text opcode.
  """
  @callback handle_in({message :: term, opts :: keyword}, state) ::
              {:ok, state} | {:stop, reason :: term, state}

  @doc """
  Handles info messages.

  The message is a term. It must return one of:

    * `{:ok, state}` - continues the socket with no reply
    * `{:push, reply, state}` - continues the socket with reply
    * `{:stop, reason, state}` - stops the socket

  The `reply` is a tuple contain an `opcode` atom and a message that can
  be any term. The built-in websocket transport supports both `:plain` and
  `:binary` opcode and the message must be always iodata. Long polling only
  supports text opcode.
  """
  @callback handle_info(message :: term, state) ::
              {:ok, state}
              | {:push, {opcode :: atom, message :: term}, state}
              | {:stop, reason :: term, state}

  @doc """
  Invoked on termination.

  If `reason` is `:closed`, it means the client closed the socket. This is
  considered a `:normal` exit signal, so linked process will not automatically
  exit. See `Process.exit/2` for more details on exit signals.
  """
  @callback terminate(reason :: term, state) :: :ok
end
