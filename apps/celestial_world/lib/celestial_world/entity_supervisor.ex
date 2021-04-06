defmodule CelestialNetwork.EntitySupervisor do
  use DynamicSupervisor

  def start_link(opts) do
    DynamicSupervisor.start_link(__MODULE__, opts, name: __MODULE__)
  end

  @impl true
  def init(_opts) do
    DynamicSupervisor.init(strategy: :one_for_one)
  end

  def start_identity(event, params, socket) do
    spec = %{
      id: CelestialWorld.IdentityEntity,
      start: {CelestialWorld.IdentityEntity, :start_link, [event, params, socket]}
    }

    case DynamicSupervisor.start_child(__MODULE__, spec) do
      {:ok, pid} ->
        {:ok, pid}

      {:error, {:already_started, pid}} ->
        DynamicSupervisor.terminate_child(__MODULE__, pid)
        start_identity(event, params, socket)

      {:error, reason} ->
        {:error, reason}
    end
  end

  def start_character(event, params, socket) do
    spec = %{
      id: CelestialWorld.CharacterEntity,
      start: {CelestialWorld.CharacterEntity, :start_link, [event, params, socket]}
    }

    case DynamicSupervisor.start_child(__MODULE__, spec) do
      {:ok, pid} ->
        {:ok, pid}

      {:error, {:already_started, pid}} ->
        DynamicSupervisor.terminate_child(__MODULE__, pid)
        start_character(event, params, socket)

      {:error, reason} ->
        {:error, reason}
    end
  end
end
