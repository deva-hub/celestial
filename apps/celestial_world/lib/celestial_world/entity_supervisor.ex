defmodule Nostalex.EntitySupervisor do
  use DynamicSupervisor

  def start_link(opts) do
    DynamicSupervisor.start_link(__MODULE__, opts, name: __MODULE__)
  end

  @impl true
  def init(_opts) do
    DynamicSupervisor.init(strategy: :one_for_one)
  end

  def start_character(socket, character) do
    spec = %{
      id: CelestialWorld.CharacterEntity,
      start: {CelestialWorld.CharacterEntity, :start_link, [socket, character]}
    }

    case DynamicSupervisor.start_child(__MODULE__, spec) do
      {:ok, pid} ->
        {:ok, pid}

      {:error, {:already_started, pid}} ->
        DynamicSupervisor.terminate_child(__MODULE__, pid)
        start_character(socket, character)

      {:error, reason} ->
        {:error, reason}
    end
  end
end
