defmodule Ruisseau.Handler do
  @type state :: term()

  @doc """
  Initializes the socket state.

  This must be executed from the process that will effectively
  operate the socket.
  """
  @callback init(state) :: {:ok, state}

  @doc """
  Handles incoming socket messages.

  The message is represented as `{payload, options}`. It must
  return one of:

    * `{:ok, state}` - continues the socket with no reply
    * `{:reply, status, reply, state}` - continues the socket with reply
    * `{:stop, reason, state}` - stops the socket

  The `reply` is a tuple contain an `opcode` atom and a message that can
  be any term. The built-in websocket transport supports both `:text` and
  `:binary` opcode and the message must be always iodata. Long polling only
  supports text opcode.
  """
  @callback handle_in({message :: term, opts :: keyword}, state) ::
              {:ok, state}
              | {:reply, :ok | :error, {opcode :: atom, message :: term}, state}
              | {:stop, reason :: term, state}

  @doc """
  Handles info messages.

  The message is a term. It must return one of:

    * `{:ok, state}` - continues the socket with no reply
    * `{:push, reply, state}` - continues the socket with reply
    * `{:stop, reason, state}` - stops the socket

  The `reply` is a tuple contain an `opcode` atom and a message that can
  be any term. The built-in websocket transport supports both `:text` and
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
