defmodule CelestialNetwork.Socket.PoolSupervisor do
  use DynamicSupervisor

  def start_link(opts) do
    DynamicSupervisor.start_link(__MODULE__, opts, name: __MODULE__)
  end

  @impl true
  def init(_opts) do
    DynamicSupervisor.init(strategy: :one_for_one)
  end

  def start_child(entity, message, socket, opts) do
    spec = %{
      id: entity,
      start: {entity, :start_link, [message.event, message.payload, socket]}
    }

    case DynamicSupervisor.start_child(__MODULE__, spec) do
      {:ok, pid} ->
        {:ok, pid}

      {:error, {:already_started, pid}} ->
        DynamicSupervisor.terminate_child(__MODULE__, pid)
        start_child(entity, message, socket, opts)

      {:error, reason} ->
        {:error, reason}
    end
  end
end
