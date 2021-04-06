defmodule CelestialNetwork.Socket do
  @moduledoc false

  defmodule InvalidMessageError do
    @moduledoc """
    Raised when the socket message is invalid.
    """
    defexception [:message]
  end

  defstruct id: nil,
            assigns: %{},
            connect_info: %{},
            type: nil,
            pubsub_server: nil,
            entity: nil,
            entity_pid: nil,
            topic: nil,
            transport: nil,
            transport_pid: nil,
            serializer: nil

  @doc """
  Adds key value pairs to socket assigns.
  A single key value pair may be passed, a keyword list or map
  of assigns may be provided to be merged into existing socket
  assigns.

  ## Examples

      iex> assign(socket, :name, "Elixir")
      iex> assign(socket, name: "Elixir", logo: "💧")

  """
  def assign(socket, key, value) do
    assign(socket, [{key, value}])
  end

  def assign(socket, attrs) when is_map(attrs) or is_list(attrs) do
    %{socket | assigns: Map.merge(socket.assigns, Map.new(attrs))}
  end
end
